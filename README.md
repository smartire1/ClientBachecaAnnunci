# Bacheca annunci — Client Flutter

App mobile per consultare annunci di lavoro e candidarsi allegando un curriculum PDF. Le aziende possono registrarsi, pubblicare annunci e consultare le candidature ricevute.

## Avvio

Avvia il backend ASP.NET Core, poi esegui questi comandi dalla root del client. Sostituisci `ID_DISPOSITIVO` con l’ID mostrato da `flutter devices` e `URL_BACKEND` con l’indirizzo raggiungibile dal dispositivo.

```bash
flutter pub get
flutter devices
flutter run -d ID_DISPOSITIVO --dart-define=API_BASE_URL=URL_BACKEND
```

- **Simulatore iOS** — `http://localhost:5153` se il backend gira sullo stesso Mac. È anche il valore predefinito dell’app.
- **Emulatore Android Studio** — `http://10.0.2.2:5153` se il backend gira sullo stesso computer e ascolta su localhost. [Documentazione Android](https://developer.android.com/studio/run/emulator-networking-address)
- **Telefono fisico Android o iOS** — `http://IP_DEL_COMPUTER:5153`. Collega il telefono e il computer alla stessa Wi-Fi e avvia il backend sulla rete locale.

Su iPhone fisico puoi aggiungere `--release` per usare l’app dalla schermata Home dopo l’installazione.
