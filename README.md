# 🧾 ProductTracker
🎯 **Descrierea Proiectului**  
ProductTracker este o aplicație mobilă inovatoare dezvoltată special pentru micile afaceri din Moldova, care rezolvă problema adopției lente a tehnologiilor AI prin oferirea unei soluții accesibile și relevante pentru gestionarea inventarului.

🌐 [Landing page oficial](https://kzml8ubbg2kzuv496quv.lite.vusercontent.net/#technology)


## 🚀 Problema Rezolvată

Multe afaceri locale nu au acces la tehnologii avansate pentru monitorizarea produselor și prevenirea risipei.  
**ProductTracker democratizează accesul la AI** prin simpla scanare a facturilor fiscale.

---

## ✨ Funcționalități Cheie

- 📸 **Scanare factură cu camera** – Detectare automată produse prin AI  
- 📄 **Încărcare factură electronică** – Suport pentru PDF, JPG, PNG  
- 🤖 **Procesare AI avansată** – Utilizează MistralAI pentru extragerea datelor  
- 📊 **Dashboard inteligent** – Statistici în timp real despre produse  
- ⚠️ **Alerte expirare** – Notificări pentru produse care expiră  
- 🎨 **Interfață modernă** – Design intuitiv cu animații fluide  
- 📱 **Experiență mobilă** – Optimizat pentru utilizare cotidiană

---

## 🛠️ Tehnologii Utilizate

### 🔹 Frontend (Flutter)
- Flutter 3.0+ – Framework UI cross-platform  
- Dart – Limbaj de programare  
- Material Design 3 – Design system modern  
- Camera & File Picker – Capturare și upload imagini  
- HTTP – Comunicare cu backend-ul  

### 🔹 Backend (Python)
- FastAPI – Framework web modern și rapid  
- MistralAI – Model AI pentru procesarea imaginilor  
- MongoDB – Bază de date NoSQL  
- Pydantic – Validare și serializare date  
- python-multipart – Upload fișiere  

### 🔹 AI & Procesare
- MistralAI Pixtral-12B – Model vision pentru OCR și extragere date  
- Base64 Encoding – Procesare imagini  
- JSON Parsing – Structurare date extrase  

---

## 🚀 Utilizare

### 1. Scanarea unei Facturi

1. Deschide aplicația ProductTracker  
2. Apasă pe "Scanează Factură"  
3. Fotografiază factura sau selectează din galerie  
4. Așteaptă procesarea AI (2-5 secunde)  
5. Verifică și editează produsele detectate  
6. Salvează în inventar  

### 2. Gestionarea Produselor

- **Vizualizare toate produsele** – Lista completă cu statusuri  
- **Filtrare după status** – Toate, Expirate, Expiring Soon, Fresh  
- **Editare produse** – Modificare detalii și date expirare  
- **Marcare ca folosite** – Eliminare din inventar  
- **Statistici în timp real** – Dashboard cu metrici importante  

### 3. Sistemul de Alerte

- 🔴 **Produse expirate** – Afișare cu animații pulsante roșii  
- 🟠 **Expiring în 7 zile** – Indicatori portocalii de avertisment  
- 🟢 **Produse fresh** – Indicatori verzi pentru produse valabile  
- 📧 **Notificări email** – Rapoarte zilnice automate (opțional)  

---

## 🎨 Caracteristici Vizuale

### 🎨 Design Modern

- Gradienți dinamici pentru un aspect premium  
- Animații fluide care îmbunătățesc experiența utilizatorului  
- Cards cu shadows pentru profunzime vizuală  
- Sistem de culori inteligent bazat pe statusul produselor  

### 🌀 Feedback Vizual

- Pulse animations pentru produse expirate  
- Color-coded avatars cu zile rămase  
- Status badges pentru feedback clar  
- Smooth transitions între ecrane  

### 📱 Responsive Design

- Adaptabil pe toate screen sizes  
- Touch-friendly controale mari  
- Material Design 3 principles  
- Dark mode support *(în dezvoltare)*  

---

## 📦 Instalare și Configurare

### 🔧 Prerequisite
- ✅ Flutter SDK 3.0+  
- ✅ Python 3.8+  
- ✅ MongoDB 4.4+  
- ✅ Cont MistralAI cu API key  

### 1. Clonare Repository

```bash
git clone https://github.com/username/ProductTracker.git
cd ProductTracker
