# HTTP Systems & Defensive Security

---

## 1. DNS-Rebinding-Safe SSRF Prevention

> [!CRITICAL]
> Resolving an IP *before* passing a URL to a standard `http.Client` is vulnerable to **DNS Rebinding TOCTOU attacks**. The IP must be validated at the transport `net.Dialer.Control` layer when the TCP socket is actually dialed.

```go
package security

import (
    "context"
    "errors"
    "fmt"
    "net"
    "net/http"
    "syscall"
    "time"
)

var ErrForbiddenIP = errors.New("connection to private/internal/restricted IP address is forbidden")

func isRestrictedIP(ip net.IP) bool {
    // Convert IPv4-mapped IPv6 addresses (e.g. ::ffff:127.0.0.1) to 4-byte IPv4 representation
    if ip4 := ip.To4(); ip4 != nil {
        return ip4.IsLoopback() || // 127.0.0.0/8
            ip4.IsPrivate() || // 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
            ip4.IsLinkLocalUnicast() || // 169.254.0.0/16 (includes 169.254.169.254 cloud metadata)
            ip4.IsLinkLocalMulticast() ||
            ip4.IsUnspecified() || // 0.0.0.0
            ip4.IsMulticast() ||
            ip4.Equal(net.IPv4bcast) // 255.255.255.255
    }

    // Pure IPv6 validation
    return ip.IsLoopback() || // ::1
        ip.IsPrivate() || // fc00::/7 (Unique Local)
        ip.IsLinkLocalUnicast() || // fe80::/10
        ip.IsLinkLocalMulticast() ||
        ip.IsUnspecified() || // ::
        ip.IsMulticast()
}

func SafeHTTPClient() *http.Client {
    dialer := &net.Dialer{
        Timeout:   5 * time.Second,
        KeepAlive: 30 * time.Second,
        Control: func(network, address string, c syscall.RawConn) error {
            host, _, err := net.SplitHostPort(address)
            if err != nil {
                return fmt.Errorf("parsing dial address %s: %w", address, err)
            }
            ip := net.ParseIP(host)
            if ip != nil && isRestrictedIP(ip) {
                return fmt.Errorf("%w: target %s", ErrForbiddenIP, host)
            }
            return nil
        },
    }

    transport := &http.Transport{
        DialContext:         dialer.DialContext,
        TLSHandshakeTimeout: 5 * time.Second,
        MaxIdleConns:        100,
        MaxIdleConnsPerHost: 10,
        IdleConnTimeout:     90 * time.Second,
    }

    return &http.Client{
        Transport: transport,
        Timeout:   10 * time.Second,
        CheckRedirect: func(req *http.Request, via []*http.Request) error {
            if len(via) >= 5 {
                return errors.New("stopped after 5 redirects")
            }
            if req.URL.Scheme != "https" {
                return errors.New("insecure redirect scheme rejected (must be https)")
            }
            return nil // Redirect destination will also be dialed via SafeHTTPClient's DialContext
        },
    }
}
```

---

## 2. Symlink-Safe Path Traversal Protection

```go
package security

import (
    "errors"
    "os"
    "path/filepath"
    "strings"
)

func SafeReadUnderRoot(rootDir, userPath string) ([]byte, error) {
    absRoot, err := filepath.Abs(rootDir)
    if err != nil {
        return nil, err
    }

    targetPath := filepath.Join(absRoot, filepath.Clean("/"+userPath))
    
    // Evaluate symlinks to prevent symlink escape attacks
    realTarget, err := filepath.EvalSymlinks(targetPath)
    if err != nil {
        return nil, err
    }

    realRoot, err := filepath.EvalSymlinks(absRoot)
    if err != nil {
        return nil, err
    }

    if !strings.HasPrefix(realTarget, realRoot+string(filepath.Separator)) && realTarget != realRoot {
        return nil, errors.New("access denied: path escapes root boundary")
    }

    return os.ReadFile(realTarget)
}
```
