# 🔐 Secure Access with Tailscale

![Tailscale](https://img.shields.io/badge/tailscale-mesh--vpn-blue)
![Zero Config](https://img.shields.io/badge/setup-zero--config-green)
![Private Networking](https://img.shields.io/badge/network-private-lightgrey)

This section explains how to use **Tailscale**, a zero-config mesh VPN, to securely access your Minecraft server (or any Docker-hosted services) over a private network — even behind firewalls or NAT.

---

## 🌐 What is Tailscale?

Tailscale creates a secure virtual network between your devices using the WireGuard protocol. Once connected, you can access your server using a stable private IP (e.g., `100.x.x.x`) from anywhere.

---

### ✅ Benefits

- 🔒 End-to-end encrypted private networking
- 🌍 Access your server from any device (PC, phone, tablet)
- 🚫 No port forwarding or firewall changes required
- 🧠 Easy setup with existing Google/Microsoft login
- 🔧 Great for remote server management and backups

---

## 🛠 Install Tailscale (Ubuntu Server)

Run the following to install Tailscale:

```
curl -fsSL https://tailscale.com/install.sh | sh
```

Then start the service:

```
sudo tailscale up
```

You’ll receive a link to authenticate in your browser. Open it on any device and log in using your preferred identity provider (e.g., Google).

---


## 🔑 Verify It’s Working
After authentication, check your assigned Tailscale IP:

```
tailscale ip -4
```

You’ll see an IP like:

```
100.120.31.5
```

---


This is your server’s private address on the Tailscale network.

## 🖥 Accessing Minecraft Server via Tailscale

### ➕ Add Tailscale to Client (PC/Mac/Linux/Android/iOS)

Go to: https://tailscale.com/download

Install the app on your client machine (Windows, macOS, Linux, Android, iOS)

Log in with the same account as your server

Open Minecraft → Multiplayer

**Enter your server’s Tailscale IP (e.g., 100.120.31.5:25565)**

---


### 🔒 Restricting Access (Optional)

Want to allow only certain devices?
Log into https://login.tailscale.com/admin/machines to:

- Remove old devices
- Rename devices
- Enable ACLs (Access Control Lists)

---


### 🧩 Integration with Docker

Tailscale runs on the host, so it works seamlessly with Docker containers exposed via:

```
ports:
  - "25565:25565"
```
No need to add it to the container itself. Just ensure your Docker app listens on 0.0.0.0 or your LAN IP.

---


## 🧠 Tips

Use tailscale status to see who’s connected

Tailscale assigns a persistent IP per device — useful for scripts

Great alternative to static IPs, VPN tunnels, or public hosting

---


## 🧪 Example Commands

***Check IP and status***
```
tailscale ip -4
tailscale status
```

***Disconnect***
```
sudo tailscale down
```

***Restart service***
```
sudo tailscale up
```

---


## 📚 More Info
Official site: https://tailscale.com

Admin panel: https://login.tailscale.com/admin

Docs: https://tailscale.com/kb
