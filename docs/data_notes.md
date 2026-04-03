# E-Commerce Data Analysis – Datenaufbereitung

## Ziel

Ziel dieses Schritts ist es, einen konsistenten und analysierbaren Datensatz aufzubauen, der als Grundlage für alle weiteren Analysen dient.

Der Fokus liegt dabei auf den zentralen Entitäten einer E-Commerce-Plattform:
Bestellungen, Kunden, Produkte und Zahlungen.

---

## Datensatz

Verwendet wird der **Olist E-Commerce Datensatz** (Kaggle).

Der Datensatz enthält reale Transaktionsdaten, u. a.:

- Bestellungen  
- Bestellpositionen  
- Produkte  
- Kunden  
- Zahlungen  

---

## Überblick über die Datenstruktur

Der Datensatz ist relational aufgebaut und enthält mehrere Eins-zu-Viele-Beziehungen:

- eine Bestellung → mehrere Bestellpositionen  
- eine Bestellung → mehrere Zahlungen  
- ein Kunde (real) → mehrere Bestellungen  

Wichtiger Modellierungsaspekt:

- `customer_id` ist auf Bestellebene eindeutig (ein Datensatz pro Bestellung)  
- `customer_unique_id` repräsentiert den tatsächlichen Kunden über mehrere Bestellungen hinweg  

Diese Unterscheidung ist für spätere Analysen auf Kundenebene entscheidend.

---

## Vorgehen bei der Datenaufbereitung

Die Datenaufbereitung wurde bewusst in klar getrennte Schritte unterteilt, um Entscheidungen nachvollziehbar zu halten.

### 1. Import der Rohdaten

- CSV-Dateien wurden in ein `raw`-Schema importiert  
- Alle Spalten zunächst als `TEXT` gespeichert  

Ziel: ein vollständig verlustfreier Import ohne implizite Typkonvertierungen.

---

### 2. Datenverständnis

Vor der Transformation wurde der Datensatz strukturell analysiert.

Im Fokus standen:

- Tabellenbeziehungen  
- Schlüsselstrukturen  
- Granularität der Daten  
- mögliche Datenqualitätsprobleme  

Wichtige Beobachtungen:

- mehrere Zeitstempel bilden unterschiedliche Phasen des Bestellprozesses ab  
- Bestellpositionen liegen auf Item-Level vor (mehrere Zeilen pro Bestellung)  
- Zahlungen können auf mehrere Methoden pro Bestellung verteilt sein  
- Produktdaten enthalten fehlende Werte, insbesondere bei Kategorien  

Diese Punkte bestimmen maßgeblich, wie spätere Analysen aufgebaut werden müssen.

---

### 3. Datenbereinigung und Transformation

Bereinigte Tabellen wurden im `analytics`-Schema aufgebaut.

Durchgeführt wurden ausschließlich strukturelle Transformationen:

- Zeitstempel → `TIMESTAMP`  
- Preise und Zahlungswerte → `NUMERIC`  
- Mengen und Dimensionen → `INT`  
- Korrektur offensichtlicher Inkonsistenzen (z. B. `lenght` → `length`)  

Bewusste Entscheidung:

Es wurden **keine fachlichen Annahmen** getroffen (z. B. keine Imputation von `NULL`-Werten).

Ziel ist eine saubere, aber unverfälschte Grundlage für die Analyse.

---

### 4. Datenvalidierung

Nach der Transformation wurde geprüft, ob die Daten konsistent geblieben sind.

Durchgeführt wurden u. a.:

- Vergleich der Zeilenanzahlen (raw vs. analytics)  
- Orphan-Checks zur Überprüfung referenzieller Integrität  

Geprüfte Beziehungen:

- Bestellungen → Kunden  
- Bestellpositionen → Bestellungen  
- Bestellpositionen → Produkte  
- Zahlungen → Bestellungen  

Erst nach erfolgreicher Validierung wurden:

- Primärschlüssel  
- Fremdschlüssel  

gesetzt, um Konsistenz und Performance sicherzustellen.

---

## Designentscheidungen

- Rohdaten bleiben unverändert (Reproduzierbarkeit)  
- Transformation beschränkt sich auf Struktur, nicht auf Interpretation  
- Fachliche Logik wird bewusst in die Analyse verschoben  
- Referenzielle Integrität wird vor Constraints explizit geprüft  

---

# Order Value – Analyse & Treiber

## Ziel

Ziel der Analyse ist es, den Bestellwert auf Order-Ebene sinnvoll zu definieren und zu verstehen, wodurch hohe Bestellwerte tatsächlich entstehen.

Definition:

> Order Value = Summe aus Produktpreis und Versandkosten pro Bestellung

---

## 1. Erste Hypothese: Item Count als Treiber

Ausgangspunkt war die Annahme, dass größere Warenkörbe zu höheren Bestellwerten führen.

Beobachtung:

- Der durchschnittliche Order Value steigt mit zunehmender Anzahl an Artikeln  
- Der Effekt ist insbesondere im Bereich von 1 bis 6 Artikeln stabil sichtbar  

Einschränkung:

- Für höhere Item Counts gibt es nur sehr wenige Beobachtungen  

**Zwischenfazit:**

Auf den ersten Blick scheint der Item Count ein zentraler Treiber zu sein.

---

## 2. Einordnung über die Verteilung

Die Verteilung zeigt jedoch ein anderes Bild:

- Der Großteil der Bestellungen besteht aus genau einem Artikel  
- Mehrere Artikel pro Bestellung sind die Ausnahme  

Das relativiert die erste Hypothese deutlich.

---

## 3. Gegenprüfung: Segmentierung nach Order Value

Zur Überprüfung wurde die Perspektive umgedreht:
Statt „Item Count → Order Value“ wurde analysiert:
„Wie sehen Bestellungen mit hohem Order Value aus?“

Ergebnis:

- Der durchschnittliche Item Count steigt nur leicht mit dem Order Value  
- Auch High-Value-Orders bestehen überwiegend aus wenigen Artikeln  

**Schlussfolgerung:**

Der Zusammenhang existiert, ist aber kein dominanter Treiber.

---

## 4. Zerlegung des Order Value

Um die tatsächlichen Treiber zu identifizieren, wurde der Order Value in seine Bestandteile zerlegt:

- Produktwert  
- Versandkosten  
- Preis pro Artikel  

Beobachtung:

- Produktwert steigt stark mit dem Order Value  
- Versandkosten steigen nur moderat  
- Preis pro Artikel steigt deutlich  

---

## 5. Zentrale Erkenntnis

Hohe Bestellwerte entstehen primär durch **teure Einzelprodukte**, nicht durch größere Warenkörbe.

Der Item Count spielt eine Rolle, erklärt aber nur einen kleinen Teil der Unterschiede.

---

## 6. Einordnung

Die Analyse zeigt ein typisches Muster:

Ein plausibler Zusammenhang (mehr Artikel → höherer Wert)  
stellt sich bei genauerer Prüfung **nicht als Haupttreiber heraus**.

Erst durch Kombination aus:

- Verteilungsanalyse  
- Segmentierung  
- Zerlegung  

wird das tatsächliche Verhalten sichtbar.

---

## Kategorieanalyse: Order Value und High-Value-Verhalten

## Ziel

Untersuchung, wie Produktkategorien mit dem Order Value zusammenhängen.

Zwei Perspektiven:

- Höhe des Order Values  
- Präsenz in High-Value-Orders  

---

## Methodik

- Order Value = `price + freight_value` (Order-Level)  
- Kategorien werden pro Bestellung zugeordnet (Mehrfachzuordnung möglich)  

Kennzahlen je Kategorie:

- AVG  
- Median  
- Differenz (AVG – Median)  
- High-Value-Quote  

Definition High-Value:

> Order Value ≥ 75. Perzentil (P75)

Filter:

- nur Kategorien mit > 30 Bestellungen  
- `NULL`-Kategorien ausgeschlossen  

---

## Ergebnisse und Interpretation

Für die Einordnung wurden vier Fragen kombiniert:

- Ist das Niveau hoch?  
- Ist es stabil oder verzerrt?  
- Wie häufig tritt die Kategorie in High-Value-Orders auf?  
- Welche Rolle spielt sie im Bestellverhalten?  

---

### 1. Klare High-Value-Kategorien

Merkmale:

- hoher AVG und Median  
- geringe Differenz  
- hohe High-Value-Quote  

Diese Kategorien sind **stabile Treiber** hoher Bestellwerte.

Beispiel: `pcs`

- extrem hohes Niveau  
- sehr stabile Verteilung  
- fast ausschließlich in High-Value-Orders vertreten  

Interpretation:

Hier entstehen hohe Order Values konsistent, nicht durch Ausreißer.

---

### 2. Kategorien mit verzerrtem Order Value

Merkmale:

- hoher AVG  
- deutlich niedrigerer Median  
- große Differenz  

Interpretation:

Der Durchschnitt wird durch wenige große Bestellungen verzerrt.

Beispiel: `eletrodomesticos_2`

- wirkt stark auf den ersten Blick  
- tatsächlich instabil verteilt  

---

### 3. Kategorien als Bestandteil großer Warenkörbe

Merkmale:

- mittleres Niveau  
- stabile Verteilung  
- hohe High-Value-Quote  

Interpretation:

Diese Kategorien sind häufig Teil großer Bestellungen, aber nicht deren Haupttreiber.

---

### 4. Stabile, mittelpreisige Kategorien

Merkmale:

- mittlerer AVG und Median  
- moderate Differenz  
- durchschnittliche High-Value-Quote  

Interpretation:

Diese Kategorien zeigen ein konsistentes, aber nicht extremes Verhalten.

---

## Zentrale Erkenntnis

Ein hoher Durchschnittswert allein reicht nicht aus.

Erst die Kombination aus:

- AVG  
- Median  
- Differenz  
- High-Value-Quote  

macht sichtbar, welche Rolle eine Kategorie tatsächlich spielt.

---

## Gesamtfazit

Die Analyse zeigt klar:

- Item Count hat einen Einfluss, ist aber kein Haupttreiber  
- Der entscheidende Faktor ist der Preis pro Artikel  
- Kategorien unterscheiden sich stark in ihrer Rolle  

Hohe Bestellwerte entstehen nicht durch einen einzelnen Faktor,  
sondern durch das Zusammenspiel von:

- Preisniveau  
- Kategorie  
- (in geringerem Maße) Warenkorbgröße  