# Ilias Downloader Uni Stuttgart

Lade die Dateien aus deinen Ilias-Kursen mit nur einem Klick herunter.

## TODO

- Support für Download von Übungsabgaben hinzufügen, seit ILIAS9 komplizierter geworden

## Features

:heavy_check_mark: Synchronisierung von Ilias-Kursen oder Ilias-Ordnern in einem beliebigen Ordner

:heavy_check_mark: Synchronisierung von Unterordnern der angegebenen Ilias-Kurse/Ordner

:heavy_check_mark: Download von Dateien

:heavy_check_mark: Download von Übungsaufgaben (Abgabeübungen)

:heavy_check_mark: Bei Datei-Aktualisierungen im Ilias wird die lokale Kopie umbenannt & die Datei erneut heruntergeladen.

:heavy_check_mark: Supports Ilias 9!

## How to use

### Vorbereitungen

1. Bash
2. grep mit Perl Regex-Support
   - macOS: GNU Grep (ggrep) installieren
   - Linux: ggrep in IliasDownload.sh zu grep refactoren

### Konfiguration

Das Script `IliasDownloadInit.sh` muss vor der ersten Ausfürhung **einmalig** konfiguriert werden.

Im oberen Teil müssen **Benutzername und Passwort für Ilias** eingetragen werden. (Zeile 5)

```shell
# Enter ILIAS username and password here
# Modify here
ILIAS_USERNAME="mm1234s"
ILIAS_PASSWORD="password"
```

Im weiteren Verlauf des Scripts muss das **Basis-Verzeichnis** festgelegt werden, in das alle Ilias-Unterlagen heruntergeladen werden sollen.

```shell
# Preset your Homefolder
MY_STUDIES_FOLDER="/E/IliasTest"
```

Danach müssen alle **Ilias-Kurse oder Ilias-Ordner** eingetragen werden, die heruntergeladen werden sollen. Zu der Kurs- oder Ordner-Nummer von Ilias muss jeweils ein lokales Verzeichnis angegeben werden. Es empiehlt sich die Verwendung von absoluten Pfaden und dem Basis-verzeichnis.

Die Kurs- oder Ordner-Nummer versteckt sich in der Ilias-URL.

```shell
# Take the id of the folder/course out of the URL, e.g.
# https://www.ili.fh-aachen.de/goto_elearning_crs_604137.html
#                                                 ^^^^^^
# or
# https://www.ili.fh-aachen.de/goto_elearning_fold_604137.html
#                                                  ^^^^^^
#
# You find this link at the bottom of every folder page.
# Subfolders and exercises are automatically downloaded, too.
# You need to use absolute paths for local folders!

# Copy for every course/folder you want to download
# Modify here
fetch_folder "593215" "$MY_STUDIES_FOLDER/Digitale Services für die Energie- und Mobolitätswende"
```

Anmerkung: Die hier eingetragenen Download-Ordner müssen existieren. Falls der Download-Ordner nicht existiert, wird das Skript keine Dateien herunterladen. Dies dient zum Schutz vor falschen Konfigurationen. (Eventuelle Unterordner im Ilias-Kurs/Ilias-Ordner werden beim Synchronisieren automatisch erstellt.)

Das Skript ist nun einsatzbereit.

### Ausführung

```sh
./IliasDownloadInit.sh
```

## FAQ

#### Es werden keine Dateien heruntergeladen. Was mache ich falsch?

Die Gründe können vielfältig sein. Bitte prüfe, ob ...

- die im `IliasDownloadInit.sh` angegebenen Verzeichnisse existieren. (Das Script lädt nur in vorhandene Verzeichnisse herunter)
- Benutzername und Password korrekt sind. Falls das Passwort exotische Sonderzeichen wie `"`, `$`, `"` oder `\` enthält, müssen diese durch ein vorgestelltes Backslash `\` escaped werden.
- das `IliasDownload.sh` Script für deine Uni konfiguriert ist.

#### Welche Bedeutung hat die Datei `.il-history`?

Das Script speichert sich in dieser Datei welche Dokumente bereits heruntergeladen wurden. Wenn du diese Datei löschst, werden die Dokumente in diesem Ordner erneut heruntergeladen.
Der Name dieser Datei kann mit der Variable `HISTORY_FILE` in dem Script `IliasDownloadInit.sh` geändert werden.

#### Einzelne Dateien werden nicht heruntergeladen.

Dies kann verschiedene Gründe haben. Kontaktiere mich gerne & ich versuche zu helfen.

Ein bekanntes Problem entsteht durch zulange Dateinamen. Der Dateiname inklusive Pfad darf maximal 255 (?) Zeichen lang sein. Versuche im `IliasDownloadInit.sh` kürzere Pfade für deine Ordner anzugeben.

## Roadmap (feel free to contribute)

- Animation erstellen, die Funktionsweise des Scripts zeigt.
- Passwort nicht im Skript hinterlegen, sondern mit Eingabeaufforderung.
- Falls gewünscht, Nutzername und Passwort in `.credentials` Datei abspeichern.
- Herunterladen der Übungsaufgaben (Übungsbücher `_lm_<id>.html`) (Sowie Links aus den Übungsaufgaben)
- Anzahl der heruntergeladenenen/fehlgeschlagenenen Dateien korrigieren. (Aufgrund der parallelen Downloads falsch.)
- Herunterladen von verlinkten Videos
- Verknüpfung "Online anzeigen" erstellen
- Konfiguration für weitere Unis hinzufügen
- Hinweis einbauen, wenn es eine neue Version gibt.
- Zu lange Ilias-Dateinamen hashen, damit Datei dennoch heruntergeladen werden kann.

## Disclaimer

Dies ist kein offizielles Tool der gelisteten Bildungseinrichtungen oder von [Ilias](https://www.ilias.de/) selbst. Ich kann die Einhaltung der gegebenen Richtlinien seitens Ilias oder der jeweiligen Bildungseinrichtung nicht prüfen. Die Haftung liegt ausschließlich bei dir. Dieses nützliche Script wird bei Benutzung in kürzester Zeit viele Anfragen an den Ilias Server deiner Bildungseinrichtung stellen. Dies kann unter Umständen zur Überlastung führen. (Und könnte deshalb von deiner Bildungseinrichtung nicht gewünscht sein.)

## Credits

https://github.com/digitalshow/IliasDownload

(Ich habe lediglich ein paar Dinge geändert, damit das wundervolle Skript läuft.)
