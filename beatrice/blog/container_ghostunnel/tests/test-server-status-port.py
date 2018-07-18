#!/usr/bin/env python3

# Creates a ghostunnel. Ensures that /_status endpoint works.

from subprocess import Popen
from common import *
import urllib.request, urllib.error, urllib.parse, socket, ssl, time, os, signal, json, sys

if __name__ == "__main__":
  ghostunnel = None
  try:
    # create certs
    root = RootCert('root')
    root.create_signed_cert('server')
    root.create_signed_cert('new_server')
    root.create_signed_cert('client')

    # start ghostunnel
    # hack: point target to STATUS_PORT so that /_status doesn't 503.
    ghostunnel = run_ghostunnel(['server', '--listen={0}:13001'.format(LOCALHOST),
      '--target={0}:{1}'.format(LOCALHOST, STATUS_PORT), '--keystore=server.p12',
      '--cacert=root.crt', '--allow-ou=client',
      '--status={0}:{1}'.format(LOCALHOST, STATUS_PORT)])

    urlopen = lambda path: urllib.request.urlopen(path, cafile='root.crt')

    # block until ghostunnel is up
    TcpClient(STATUS_PORT).connect(20)
    status = json.loads(str(urlopen("https://{0}:{1}/_status".format(LOCALHOST, STATUS_PORT)).read(), 'utf-8'))
    metrics = json.loads(str(urlopen("https://{0}:{1}/_metrics".format(LOCALHOST, STATUS_PORT)).read(), 'utf-8'))

    if not status['ok']:
        raise Exception("ghostunnel reported non-ok status")

    if type(metrics) != list:
        raise Exception("ghostunnel metrics expected to be JSON list")

    # reload, check we get the new cert on /_status
    os.rename('new_server.p12', 'server.p12')
    ghostunnel.send_signal(signal.SIGUSR1)
    TlsClient(None, 'root', STATUS_PORT).connect(20, 'new_server')
    print_ok('/_status seems up')

    # read status information
    status = json.loads(str(urlopen("https://{0}:{1}/_status".format(LOCALHOST, STATUS_PORT)).read(), 'utf-8'))
    metrics = json.loads(str(urlopen("https://{0}:{1}/_metrics".format(LOCALHOST, STATUS_PORT)).read(), 'utf-8'))

    if not status['ok']:
        raise Exception("ghostunnel reported non-ok status")

    if type(metrics) != list:
        raise Exception("ghostunnel metrics expected to be JSON list")

    print_ok("OK")
  finally:
    terminate(ghostunnel)
      
