# 🔧 Minecraft Mods, Resource Packs & Shaders Setup

This guide explains how to install and manage **Mods**, **Resource Packs**, and **Shaders** in your Minecraft Fabric server.  
It also covers the configuration for **Geyser** and **Floodgate** to support Bedrock players on a Java server.

---

## 🧩 What’s the Difference?

| Type            | Description                                                                 | Installed On       | File Type       |
|------------------|------------------------------------------------------------------------------|--------------------|------------------|
| **Mod**         | Adds or changes gameplay features (e.g., new mobs, blocks, UI, automation)  | Server & Client    | `.jar` (Fabric mods) |
| **Resource Pack** | Changes textures, sounds, or UI visuals (no code changes)                   | Client (optional)  | `.zip`           |
| **Shader**      | Adds advanced graphics effects like lighting, shadows, reflections          | Client (requires OptiFine or Iris) | `.zip` |

---

## 📂 Where to Put Things

### ✅ Mods

Put your mods (e.g., `sodium.jar`, `geyser-fabric.jar`) in the following folder on your **server**:


Make sure all mods are compatible with:
- The server’s **Minecraft version**
- The **Fabric loader version**

> Mods may also be required on the **client side** (player’s PC), especially for gameplay-altering features.

---

### 🎨 Resource Packs

Resource packs are only needed **on the client**.

To install:
1. Launch Minecraft.
2. Click **Options → Resource Packs → Open Pack Folder**.
3. Place the `.zip` file there.
4. Activate it in-game.

> Server-side resource pack linking is also possible via the `server.properties` file (see `resource-pack=` and `resource-pack-sha1=`).

---

### 🌅 Shaders

Shaders are also **client-side only**.

To install:
1. Install **Iris** or **OptiFine** on your client.
2. Launch the game and go to **Video Settings → Shader Packs → Open Shaderpacks Folder**.
3. Drop the shader `.zip` inside.
4. Enable in-game.

Popular shaders include **Complementary**, **BSL**, and **Sildur’s Vibrant**.

---

## 🌉 Geyser & Floodgate Setup (Bedrock Support)

Geyser and Floodgate allow **Bedrock Edition** players to join a **Java server** — no extra server needed.

### 🔌 Step 1: Install the Mods

Copy the following `.jar` files into your server's `mods/` folder:
- `geyser-fabric.jar`
- `floodgate-fabric.jar`

> ✅ Make sure both match the server’s Minecraft & Fabric versions.

---

### ⚙️ Step 2: First Launch to Generate Configs

Start your server once to auto-generate the Geyser and Floodgate config files inside:

```
/home/<your_user>/minecraft_servers/<server_folder>/mods/
```


Make sure all mods are compatible with:
- The server’s **Minecraft version**
- The **Fabric loader version**

> Mods may also be required on the **client side** (player’s PC), especially for gameplay-altering features.

---

### 🎨 Resource Packs

Resource packs are only needed **on the client**.

To install:
1. Launch Minecraft.
2. Click **Options → Resource Packs → Open Pack Folder**.
3. Place the `.zip` file there.
4. Activate it in-game.

> Server-side resource pack linking is also possible via the `server.properties` file (see `resource-pack=` and `resource-pack-sha1=`).

---

### 🌅 Shaders

Shaders are also **client-side only**.

To install:
1. Install **Iris** or **OptiFine** on your client.
2. Launch the game and go to **Video Settings → Shader Packs → Open Shaderpacks Folder**.
3. Drop the shader `.zip` inside.
4. Enable in-game.

Popular shaders include **Complementary**, **BSL**, and **Sildur’s Vibrant**.

---

## 🌉 Geyser & Floodgate Setup (Bedrock Support)

Geyser and Floodgate allow **Bedrock Edition** players to join a **Java server** — no extra server needed.

### 🔌 Step 1: Install the Mods

Copy the following `.jar` files into your server's `mods/` folder:
- `geyser-fabric.jar`
- `floodgate-fabric.jar`

> ✅ Make sure both match the server’s Minecraft & Fabric versions.

---

### ⚙️ Step 2: First Launch to Generate Configs

Start your server once to auto-generate the Geyser and Floodgate config files inside:

```
/home/<your_user>/minecraft_servers/<server_folder>/config/
```

You should see:
- `geyser-fabric.yml`
- `floodgate.yml`

---

### ✏️ Step 3: Configure Geyser

Open the file `config/geyser-fabric.yml` and adjust the following:

```yaml
bedrock:
  port: 19132
  address: 0.0.0.0

remote:
  address: 127.0.0.1
  port: 25565
  auth-type: floodgate

This setup allows Bedrock players to connect to your Java world on port 19132 (the default Bedrock port).

You can now connect using:

Java: your-server-ip:25565

Bedrock: your-server-ip:19132
