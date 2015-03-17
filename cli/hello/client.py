# -*- coding: utf-8 -*-

"""Example usage of PyHawk - A python hawk library from Mozilla."""

import requests

from hawk.client import header as hawk_header

def main():
    """ Call the hello service from the command line. """
    credentials = { 'algorithm': 'sha256', 'id': 'bb190a0c210f',
        'key': 'saRgjL5mz305xgKdKm7wtyH3uXbJb1YMtGEFbiGB5kAukFessyq1KiVNJ3rGDPT' }
    url = 'http://localhost/hello/api/greeting/Hawk'
    header = hawk_header(url, 'GET', { 'credentials': credentials, 'ext': 'PyHawk!' })
    headers = { 'Authorization':header['field'], 'Accept-Version':'~2' }
    res = requests.get(url, data={}, headers=headers)
    if (200 != res.status_code):
        print 'Authorized request (FAILED) status=' + str(res.status_code) + ' body=' + res.text
    else:
        print 'status =', res.status_code
        print 'headers =', res.headers
        print 'body =', res.text

if __name__ == '__main__':
    main()
