//! Tarmoq skanerlash va xavfsizlik tahlili

use serde::{Deserialize, Serialize};
use std::net::{IpAddr, SocketAddr, TcpStream};
use std::time::{Duration, Instant};

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct ScanResult {
    pub host: String,
    pub ip: String,
    pub open_ports: Vec<PortInfo>,
    pub scan_duration_ms: u64,
    pub total_scanned: u32,
    pub os_guess: Option<String>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct PortInfo {
    pub port: u16,
    pub service: String,
    pub banner: Option<String>,
    pub response_time_ms: u64,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct SecurityTip {
    pub id: u32,
    pub title: String,
    pub description: String,
    pub category: String,
    pub priority: String,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct IpInfo {
    pub ip: String,
    pub is_private: bool,
    pub is_loopback: bool,
    pub is_multicast: bool,
    pub version: String,
    pub class: String,
}

pub fn scan_ip_range(base: &str, start_port: u16, end_port: u16, timeout_ms: u64) -> Vec<ScanResult> {
    let timeout = Duration::from_millis(timeout_ms.max(100).min(10000));
    let mut results = Vec::new();
    for i in 1..=254 {
        let ip = format!("{}.{}", base, i);
        if let Ok(addr) = ip.parse::<IpAddr>() {
            let start = Instant::now();
            if let Ok(_stream) = TcpStream::connect_timeout(&SocketAddr::new(addr, start_port.max(1)), timeout) {
                let ports = scan_ports(&ip, start_port, end_port, timeout_ms);
                results.push(ScanResult {
                    host: format!("host-{}", i), ip: ip.clone(),
                    open_ports: ports.open_ports,
                    scan_duration_ms: start.elapsed().as_millis() as u64,
                    total_scanned: (end_port - start_port + 1) as u32,
                    os_guess: guess_os(&ip),
                });
            }
        }
    }
    results
}

pub fn scan_ports(host: &str, start_port: u16, end_port: u16, timeout_ms: u64) -> ScanResult {
    let timeout = Duration::from_millis(timeout_ms.max(100).min(10000));
    let mut open_ports = Vec::new();
    let start = Instant::now();
    let start_p = start_port.max(1);
    let end_p = end_port.min(65535);
    for port in start_p..=end_p {
        if let Ok(addr) = format!("{}:{}", host, port).parse::<SocketAddr>() {
            let port_start = Instant::now();
            if let Ok(stream) = TcpStream::connect_timeout(&addr, timeout) {
                open_ports.push(PortInfo {
                    port, service: identify_service(port),
                    banner: grab_banner(&stream),
                    response_time_ms: port_start.elapsed().as_millis() as u64,
                });
            }
        }
    }
    ScanResult {
        host: host.to_string(), ip: host.to_string(), open_ports,
        scan_duration_ms: start.elapsed().as_millis() as u64,
        total_scanned: (end_p - start_p + 1) as u32,
        os_guess: guess_os(host),
    }
}

fn identify_service(port: u16) -> String {
    match port {
        21 => "FTP", 22 => "SSH", 23 => "Telnet", 25 => "SMTP",
        53 => "DNS", 80 => "HTTP", 110 => "POP3", 143 => "IMAP",
        443 => "HTTPS", 445 => "SMB", 3306 => "MySQL", 3389 => "RDP",
        5432 => "PostgreSQL", 8080 => "HTTP-Proxy", 8443 => "HTTPS-Alt",
        _ => "Unknown",
    }.to_string()
}

fn grab_banner(_stream: &TcpStream) -> Option<String> { None }
fn guess_os(_host: &str) -> Option<String> { Some("Unknown".to_string()) }

pub fn get_ip_info(ip: &str) -> IpInfo {
    let parsed = ip.parse::<IpAddr>();
    let (is_private, is_loopback, is_multicast, version, class) = match parsed {
        Ok(IpAddr::V4(ipv4)) => {
            let octets = ipv4.octets();
            let is_priv = octets[0] == 10
                || (octets[0] == 172 && (16..=31).contains(&octets[1]))
                || (octets[0] == 192 && octets[1] == 168);
            let class = if octets[0] < 128 { "A" }
                else if octets[0] < 192 { "B" }
                else if octets[0] < 224 { "C" }
                else if octets[0] < 240 { "D" }
                else { "E" };
            (is_priv, ipv4.is_loopback(), ipv4.is_multicast(), "IPv4".to_string(), class.to_string())
        }
        Ok(IpAddr::V6(_)) => (false, false, false, "IPv6".to_string(), "N/A".to_string()),
        Err(_) => (false, false, false, "Invalid".to_string(), "N/A".to_string()),
    };
    IpInfo { ip: ip.to_string(), is_private, is_loopback, is_multicast, version, class }
}

pub fn get_security_tips() -> Vec<SecurityTip> {
    vec![
        SecurityTip { id: 1, title: "Kuchli parollar ishlating".to_string(),
            description: "Kamida 12 ta belgidan iborat parol tanlang".to_string(),
            category: "Parollar".to_string(), priority: "high".to_string() },
        SecurityTip { id: 2, title: "Ikki bosqichli autentifikatsiya (2FA)".to_string(),
            description: "Barcha muhim hisoblaringizda 2FA yoqing".to_string(),
            category: "Autentifikatsiya".to_string(), priority: "high".to_string() },
        SecurityTip { id: 3, title: "Dasturiy ta'minotni yangilang".to_string(),
            description: "OS va ilovalarni doimiy yangilab turing".to_string(),
            category: "Yangilanishlar".to_string(), priority: "high".to_string() },
        SecurityTip { id: 4, title: "Shubhali linklarni bosmang".to_string(),
            description: "Phishing hujumlariga ehtiyot bo'ling".to_string(),
            category: "Phishing".to_string(), priority: "high".to_string() },
        SecurityTip { id: 5, title: "Zaxira nusxalar yarating".to_string(),
            description: "Muhim ma'lumotlaringizni muntazam zaxiralang".to_string(),
            category: "Zaxira".to_string(), priority: "medium".to_string() },
        SecurityTip { id: 6, title: "Public WiFi'da ehtiyot bo'ling".to_string(),
            description: "Ochiq tarmoqlarda VPN ishlating".to_string(),
            category: "Tarmoq".to_string(), priority: "high".to_string() },
        SecurityTip { id: 7, title: "Antivirus dasturini o'rnating".to_string(),
            description: "Ishonchli antivirus dasturini o'rnating".to_string(),
            category: "Antivirus".to_string(), priority: "medium".to_string() },
        SecurityTip { id: 8, title: "Ilova ruxsatlarini nazorat qiling".to_string(),
            description: "Ilovalarga bergan ruxsatlarini tekshirib oling".to_string(),
            category: "Maxfiylik".to_string(), priority: "medium".to_string() },
    ]
}
