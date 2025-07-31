import unittest

from unbound_cache_exporter import process_cache_dump

# A sample fixture representing the output of 'unbound-control dump_cache'
# This contains various types of domains to test the filtering logic.
SAMPLE_CACHE_DUMP = """
CACHE DUMP:
msg . IN DNSKEY 39159 1 0 0 -1
msg com. IN DNSKEY 22583 1 0 0 -1
msg co.uk. IN DNSKEY 3586 1 0 0 -1
msg bbc.co.uk. IN A 3586 1 0 0 6
msg google.com. IN A 3571 1 0 0 6
msg example.com. IN A 3500 1 0 0 6
msg invalid-tld. IN A 3400 1 0 0 6
msg api.github.com. IN AAAA 3594 1 0 0 6
msg net. IN DS 50764 1 0 0 -1
"""


class TestCacheProcessing(unittest.TestCase):

    def test_domain_filtering(self):
        """
        Tests that the processing function correctly filters a sample cache dump.
        - It should KEEP registrable domains (google.com, bbc.co.uk).
        - It should DISCARD public suffixes (com, co.uk, net).
        - It should handle various record types correctly.
        """
        # The expected result after processing the sample dump
        expected_domains = [
            "api.github.com",
            "bbc.co.uk",
            "example.com",
            "google.com",
        ]

        # Process the sample data
        result_domains = process_cache_dump(SAMPLE_CACHE_DUMP)

        # Assert that the result matches the expected list
        self.assertEqual(result_domains, expected_domains)


if __name__ == "__main__":
    unittest.main()
