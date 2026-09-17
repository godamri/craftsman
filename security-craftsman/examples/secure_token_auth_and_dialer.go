package main

import (
	"crypto/subtle"
	"errors"
	"fmt"
	"net"
	"net/url"
)

// ==============================================================================
// 1. CONSTANT-TIME TOKEN VALIDATION
// ==============================================================================

func ValidateSecretToken(provided, expected string) bool {
	// Prevents timing attacks
	return subtle.ConstantTimeCompare([]byte(provided), []byte(expected)) == 1
}

// ==============================================================================
// 2. SSRF & PRIVATE IP VALIDATOR
// ==============================================================================

var privateIPBlocks []*net.IPNet

func init() {
	// Initialize CIDRs for loopback, private, link-local subnets
	cidrs := []string{
		"127.0.0.0/8",    // IPv4 loopback
		"10.0.0.0/8",     // RFC1918 Class A
		"172.16.0.0/12",  // RFC1918 Class B
		"192.168.0.0/16", // RFC1918 Class C
		"169.254.0.0/16", // RFC3927 Link-local
		"::1/128",        // IPv6 loopback
		"fc00::/7",       // IPv6 Unique Local Address
		"fe80::/10",      // IPv6 Link-local
	}

	for _, cidr := range cidrs {
		_, block, err := net.ParseCIDR(cidr)
		if err != nil {
			panic(err)
		}
		privateIPBlocks = append(privateIPBlocks, block)
	}
}

func isPrivateOrLoopbackIP(ip net.IP) bool {
	for _, block := range privateIPBlocks {
		if block.Contains(ip) {
			return true
		}
	}
	return false
}

// ValidateTargetURLForSSRF parses the URL and resolves host to verify non-private IPs.
func ValidateTargetURLForSSRF(rawURL string) (*net.IP, error) {
	parsed, err := url.Parse(rawURL)
	if err != nil {
		return nil, fmt.Errorf("invalid URL: %w", err)
	}

	if parsed.Scheme != "http" && parsed.Scheme != "https" {
		return nil, errors.New("only http and https schemes are permitted")
	}

	hostname := parsed.Hostname()
	ips, err := net.LookupIP(hostname)
	if err != nil {
		return nil, fmt.Errorf("DNS resolution failed for %s: %w", hostname, err)
	}

	for _, ip := range ips {
		if isPrivateOrLoopbackIP(ip) {
			return nil, fmt.Errorf("SSRF violation: hostname %s resolved to protected IP %s", hostname, ip.String())
		}
	}

	if len(ips) == 0 {
		return nil, errors.New("no IP addresses found for host")
	}

	return &ips[0], nil
}

func main() {
	fmt.Println("=== SECURITY CRAFTSMAN: DEFENSIVE VALIDATION RUNNER ===")

	// 1. Test Constant-Time Token Validation
	expectedToken := "secret_bearer_token_xyz_789"
	valid := ValidateSecretToken("secret_bearer_token_xyz_789", expectedToken)
	invalid := ValidateSecretToken("wrong_token_guess_000", expectedToken)

	fmt.Printf("1. Constant-Time Auth: Valid Token=%v, Invalid Token=%v\n", valid, invalid)

	// 2. Test SSRF Guard
	testURLs := []string{
		"http://127.0.0.1/admin",
		"http://169.254.169.254/latest/meta-data/",
		"http://192.168.1.1/router",
		"http://localhost:8080/metrics",
	}

	for _, u := range testURLs {
		_, err := ValidateTargetURLForSSRF(u)
		if err != nil {
			fmt.Printf("2. SSRF Protection: Blocked target %s -> %v\n", u, err)
		} else {
			panic(fmt.Sprintf("Failed to block SSRF URL %s", u))
		}
	}

	fmt.Println("=== ALL DEFENSIVE SECURITY CONTROLS VERIFIED ===")
}
