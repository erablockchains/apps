"""No-network checks for the provenance token's host boundary."""
from pathlib import Path
import os
import runpy
import unittest
import urllib.request
from unittest.mock import patch

gate = runpy.run_path(str(Path(__file__).with_name('verify-era-ios-source.py')))


class TokenBoundary(unittest.TestCase):
    @patch.dict(os.environ, {'ERA_GITHUB_READ_TOKEN': 'synthetic-test-token'})
    def test_only_https_api_receives_authorization(self):
        headers = gate['request_headers']
        self.assertEqual(headers('https://api.github.com/repos/erablockchains/apps')['Authorization'], 'Bearer synthetic-test-token')
        for url in ['https://raw.githubusercontent.com/erablockchains/apps/master/file',
                    'https://api.github.com.example.test/',
                    'https://api.github.com@other.example/',
                    'http://api.github.com/', 'https://api.github.com:444/']:
            self.assertNotIn('Authorization', headers(url))

    @patch.dict(os.environ, {'ERA_GITHUB_READ_TOKEN': 'synthetic-test-token'})
    def test_cross_host_redirect_removes_authorization(self):
        original = urllib.request.Request('https://api.github.com/repos/erablockchains/apps', headers=gate['request_headers']('https://api.github.com/'))
        redirected = gate['ScopedAuthorizationRedirect']().redirect_request(original, None, 302, 'Found', {}, 'https://raw.githubusercontent.com/public/file')
        self.assertIsNone(redirected.get_header('Authorization'))


if __name__ == '__main__':
    unittest.main()
