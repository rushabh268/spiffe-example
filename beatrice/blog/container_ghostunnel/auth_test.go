/*-
 * Copyright 2015 Square Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package main

import (
	"crypto/x509"
	"crypto/x509/pkix"
	"net"
	"testing"

	"github.com/spiffe/go-spiffe/uri"
	"github.com/stretchr/testify/assert"
)

var fakeChains = [][]*x509.Certificate{
	{
		{
			Subject: pkix.Name{
				CommonName:         "gopher",
				OrganizationalUnit: []string{"triangle", "circle"},
			},
			DNSNames:    []string{"circle"},
			IPAddresses: []net.IP{net.IPv4(192, 168, 99, 100)},
			Extensions: []pkix.Extension{
				{
					Id:       uri.OidExtensionSubjectAltName,
					Value:    getURISANFromString("scheme://valid/path"),
					Critical: false,
				},
			},
		},
	},
}

func getURISANFromString(s string) (uriSAN []byte) {
	uriSAN, err := uri.MarshalUriSANs([]string{s})
	panicOnError(err)

	return uriSAN
}

func TestAuthorizeNotVerified(t *testing.T) {
	*serverAllowAll = true
	*serverAllowedCNs = []string{}
	*serverAllowedOUs = []string{}
	*serverAllowedDNSs = []string{}
	*serverAllowedIPs = []net.IP{}
	*serverAllowedURIs = []string{}

	assert.NotNil(t, verifyPeerCertificateServer(nil, nil), "conn w/o cert should be rejected")
}

func TestAuthorizeReject(t *testing.T) {
	*serverAllowAll = false
	*serverAllowedCNs = []string{"test"}
	*serverAllowedOUs = []string{"test"}
	*serverAllowedDNSs = []string{"test"}
	*serverAllowedIPs = []net.IP{}
	*serverAllowedURIs = []string{"test"}

	assert.NotNil(t, verifyPeerCertificateServer(nil, fakeChains), "should reject cert w/o matching CN/OU")
}

func TestAuthorizeAllowAll(t *testing.T) {
	*serverAllowAll = true
	*serverAllowedCNs = []string{}
	*serverAllowedOUs = []string{}
	*serverAllowedDNSs = []string{}
	*serverAllowedIPs = []net.IP{}

	assert.Nil(t, verifyPeerCertificateServer(nil, fakeChains), "allow-all should always allow authed clients")
}

func TestAuthorizeAllowCN(t *testing.T) {
	*serverAllowAll = false
	*serverAllowedCNs = []string{"gopher"}
	*serverAllowedOUs = []string{}
	*serverAllowedDNSs = []string{}
	*serverAllowedIPs = []net.IP{}
	*serverAllowedURIs = []string{}

	assert.Nil(t, verifyPeerCertificateServer(nil, fakeChains), "allow-cn should allow clients with matching CN")
}

func TestAuthorizeAllowOU(t *testing.T) {
	*serverAllowAll = false
	*serverAllowedCNs = []string{}
	*serverAllowedOUs = []string{"circle"}
	*serverAllowedDNSs = []string{}
	*serverAllowedIPs = []net.IP{}
	*serverAllowedURIs = []string{}

	assert.Nil(t, verifyPeerCertificateServer(nil, fakeChains), "allow-ou should allow clients with matching OU")
}

func TestAuthorizeAllowDNS(t *testing.T) {
	*serverAllowAll = false
	*serverAllowedCNs = []string{}
	*serverAllowedOUs = []string{}
	*serverAllowedDNSs = []string{"circle"}
	*serverAllowedIPs = []net.IP{}
	*serverAllowedURIs = []string{}

	assert.Nil(t, verifyPeerCertificateServer(nil, fakeChains), "allow-dns-san should allow clients with matching DNS SAN")
}

func TestAuthorizeAllowIP(t *testing.T) {
	*serverAllowAll = false
	*serverAllowedCNs = []string{}
	*serverAllowedOUs = []string{}
	*serverAllowedDNSs = []string{}
	*serverAllowedIPs = []net.IP{net.IPv4(192, 168, 99, 100)}
	*serverAllowedURIs = []string{}

	assert.Nil(t, verifyPeerCertificateServer(nil, fakeChains), "allow-ip-san should allow clients with matching IP SAN")
}

func TestAuthorizeAllowURI(t *testing.T) {
	*serverAllowAll = false
	*serverAllowedCNs = []string{}
	*serverAllowedOUs = []string{}
	*serverAllowedDNSs = []string{}
	*serverAllowedIPs = []net.IP{}
	*serverAllowedURIs = []string{"scheme://valid/path"}

	assert.Nil(t, verifyPeerCertificateServer(nil, fakeChains), "allow-uri-san should allow clients with matching URI SAN")
}

func TestAuthorizeRejectURI(t *testing.T) {
	*serverAllowAll = false
	*serverAllowedCNs = []string{}
	*serverAllowedOUs = []string{}
	*serverAllowedDNSs = []string{}
	*serverAllowedIPs = []net.IP{}
	*serverAllowedURIs = []string{"schema://invalid/path"}

	assert.NotNil(t, verifyPeerCertificateServer(nil, fakeChains), "should reject cert w/o matching URI")
}

func TestVerifyAllowCN(t *testing.T) {
	*clientAllowedCNs = []string{"gopher"}
	*clientAllowedOUs = []string{}
	*clientAllowedDNSs = []string{}
	*clientAllowedIPs = []net.IP{}

	assert.Nil(t, verifyPeerCertificateClient(nil, fakeChains), "verify-cn should allow servers with matching CN")
}

func TestVerifyAllowOU(t *testing.T) {
	*clientAllowedCNs = []string{}
	*clientAllowedOUs = []string{"circle"}
	*clientAllowedDNSs = []string{}
	*clientAllowedIPs = []net.IP{}

	assert.Nil(t, verifyPeerCertificateClient(nil, fakeChains), "verify-ou should allow servers with matching OU")
}

func TestVerifyAllowDNS(t *testing.T) {
	*clientAllowedCNs = []string{}
	*clientAllowedOUs = []string{}
	*clientAllowedDNSs = []string{"circle"}
	*clientAllowedIPs = []net.IP{}

	assert.Nil(t, verifyPeerCertificateClient(nil, fakeChains), "verify-dns-san should allow servers with matching DNS SAN")
}

func TestVerifyAllowIP(t *testing.T) {
	*clientAllowedCNs = []string{}
	*clientAllowedOUs = []string{}
	*clientAllowedDNSs = []string{}
	*clientAllowedIPs = []net.IP{net.IPv4(192, 168, 99, 100)}

	assert.Nil(t, verifyPeerCertificateClient(nil, fakeChains), "verify-ip-san should allow servers with matching IP SAN")
}

func TestVerifyRejectCN(t *testing.T) {
	*clientAllowedCNs = []string{"test"}
	*clientAllowedOUs = []string{}
	*clientAllowedDNSs = []string{}
	*clientAllowedIPs = []net.IP{}

	assert.NotNil(t, verifyPeerCertificateClient(nil, fakeChains), "should reject cert w/o matching CN")
}

func TestVerifyRejectOU(t *testing.T) {
	*clientAllowedCNs = []string{}
	*clientAllowedOUs = []string{"test"}
	*clientAllowedDNSs = []string{}
	*clientAllowedIPs = []net.IP{}

	assert.NotNil(t, verifyPeerCertificateClient(nil, fakeChains), "should reject cert w/o matching OU")
}

func TestVerifyRejectDNS(t *testing.T) {
	*clientAllowedCNs = []string{}
	*clientAllowedOUs = []string{}
	*clientAllowedDNSs = []string{"test"}
	*clientAllowedIPs = []net.IP{}

	assert.NotNil(t, verifyPeerCertificateClient(nil, fakeChains), "should reject cert w/o matching DNS SAN")
}

func TestVerifyRejectIP(t *testing.T) {
	*clientAllowedCNs = []string{}
	*clientAllowedOUs = []string{}
	*clientAllowedDNSs = []string{}
	*clientAllowedIPs = []net.IP{net.IPv4(1, 1, 1, 1)}

	assert.NotNil(t, verifyPeerCertificateClient(nil, fakeChains), "should reject cert w/o matching IP SAN")
}

func TestVerifyAllowURI(t *testing.T) {
	*clientAllowedCNs = []string{}
	*clientAllowedOUs = []string{}
	*clientAllowedDNSs = []string{}
	*clientAllowedIPs = []net.IP{}
	*clientAllowedURIs = []string{"scheme://valid/path"}

	assert.Nil(t, verifyPeerCertificateClient(nil, fakeChains), "verify-uri-san should allow clients with matching URI SAN")
}

func TestVerifyRejectURI(t *testing.T) {
	*clientAllowedCNs = []string{}
	*clientAllowedOUs = []string{}
	*clientAllowedDNSs = []string{}
	*clientAllowedIPs = []net.IP{}
	*clientAllowedURIs = []string{"scheme://invalid/path"}

	assert.NotNil(t, verifyPeerCertificateClient(nil, fakeChains), "should reject cert w/o matching URI")
}
