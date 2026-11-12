#ifndef KIBERXAVFLIY_CORE_H
#define KIBERXAVFLIY_CORE_H

#include <stdint.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

void kx_free_string(char* ptr);
char* kx_version(void);

char* kx_scan_network(const char* base_ip, int32_t start_port, int32_t end_port, int32_t timeout_ms);
char* kx_scan_ports(const char* host, int32_t start_port, int32_t end_port, int32_t timeout_ms);
char* kx_check_ssl(const char* host, int32_t port);

double kx_analyze_password(const char* password);
char* kx_password_details(const char* password);

char* kx_sha256(const char* input);
char* kx_md5(const char* input);
char* kx_base64_encode(const char* input);
char* kx_base64_decode(const char* input);
char* kx_generate_password(int32_t length, int32_t include_special);

char* kx_security_tips(void);
char* kx_ip_info(const char* ip);

#ifdef __cplusplus
}
#endif

#endif
