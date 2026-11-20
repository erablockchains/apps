import importlib.util
from pathlib import Path
import subprocess
import tempfile
import unittest

SPEC = importlib.util.spec_from_file_location('harness', Path(__file__).with_name('install-review-test-harness.py'))
MOD = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MOD)

class HarnessOverlayTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.source, self.harness = self.base/'source', self.base/'harness'
        for root in (self.source, self.harness):
            root.mkdir()
            subprocess.run(['git','init','-q',str(root)],check=True)
            for relative in (*MOD.ALLOWED, 'era-wallet/lib/main.dart', 'era-wallet/ios/Runner/Info.plist', 'era-wallet/pubspec.lock'):
                path=root/relative
                path.parent.mkdir(parents=True,exist_ok=True)
                path.write_text('reviewed fixture '+relative)
            subprocess.run(['git','-C',str(root),'add','.'],check=True)
            subprocess.run(['git','-C',str(root),'-c','user.name=Fixture','-c','user.email=fixture@example.invalid','commit','-qm','fixture'],check=True)
        self.source_sha=self.sha(self.source)
        self.harness_sha=self.sha(self.harness)
        for relative in MOD.ALLOWED:
            (self.harness/relative).write_text('updated test '+relative)
        subprocess.run(['git','-C',str(self.harness),'add','.'],check=True)
        subprocess.run(['git','-C',str(self.harness),'-c','user.name=Fixture','-c','user.email=fixture@example.invalid','commit','-qm','reviewed tests'],check=True)
        self.harness_sha=self.sha(self.harness)

    def sha(self, root):
        return subprocess.check_output(['git','-C',str(root),'rev-parse','HEAD'],text=True).strip()

    def test_only_allowed_test_files_change(self):
        protected=self.source/'era-wallet/lib/main.dart'
        original=protected.read_bytes()
        (self.harness/'era-wallet/lib/main.dart').write_text('must never copy app code')
        result=MOD.install(self.source,self.harness,self.source_sha,self.harness_sha)
        self.assertEqual(protected.read_bytes(),original)
        self.assertTrue(result['protected_files_unchanged'])
        self.assertEqual(set(result['test_files_sha256']),set(MOD.ALLOWED))
        for relative in MOD.ALLOWED:
            self.assertEqual((self.source/relative).read_bytes(),(self.harness/relative).read_bytes())

    def test_wrong_release_sha_is_rejected(self):
        with self.assertRaisesRegex(ValueError,'Release checkout'):
            MOD.install(self.source,self.harness,'0'*40,self.harness_sha)

    def test_wrong_harness_sha_is_rejected(self):
        with self.assertRaisesRegex(ValueError,'Harness checkout'):
            MOD.install(self.source,self.harness,self.source_sha,'0'*40)

    def test_short_sha_is_rejected(self):
        with self.assertRaisesRegex(ValueError,'Full reviewed SHA'):
            MOD.install(self.source,self.harness,self.source_sha[:8],self.harness_sha)

if __name__ == '__main__':
    unittest.main()
