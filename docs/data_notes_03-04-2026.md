# E-Commerce Data Analysis – Datenaufbereitung

## Ziel

Einen strukturierten und verlässlichen Datensatz für die Analyse einer E-Commerce-Plattform vorbereiten, mit Fokus auf Bestellungen, Kunden, Produkte und Zahlungen.

---

## Datensatz

Das Projekt verwendet den **Olist E-Commerce Datensatz** (Kaggle).

Der Datensatz enthält Transaktionsdaten, darunter:

- Bestellungen  
- Bestellpositionen  
- Produkte  
- Kunden  
- Zahlungen  

---

## Überblick über die Datenstruktur

Der Datensatz folgt einer relationalen Struktur mit mehreren Eins-zu-Viele-Beziehungen:

- eine Bestellung → mehrere Bestellpositionen  
- eine Bestellung → mehrere Zahlungen  
- ein Kunde (real) → mehrere Bestellungen  

Wichtiger Modellierungsaspekt:

- `customer_id` repräsentiert einen kundenbezogenen Datensatz auf Bestellebene  
- `customer_unique_id` repräsentiert den tatsächlichen Kunden über mehrere Bestellungen hinweg  

---

## Vorgehen bei der Datenaufbereitung

Der Prozess der Datenaufbereitung wurde in vier Hauptschritte unterteilt:

### 1. Import der Rohdaten

- Die CSV-Dateien wurden in ein `raw`-Schema importiert  
- Alle Spalten wurden als `TEXT` gespeichert, um einen verlustfreien Import sicherzustellen  
- Es wurden in diesem Schritt keine Transformationen durchgeführt  

---

### 2. Datenverständnis

Der Datensatz wurde analysiert, um folgende Aspekte zu verstehen:

- Tabellenbeziehungen  
- Primär- und Fremdschlüssel  
- Granularität der Daten  
- mögliche Datenqualitätsprobleme  

Zentrale Beobachtungen:

- mehrere Zeitstempel repräsentieren verschiedene Phasen des Bestellprozesses  
- Bestellpositionen liegen auf Item-Ebene vor (mehrere Zeilen pro Bestellung)  
- Zahlungen können auf mehrere Zahlungsmethoden pro Bestellung verteilt sein  
- Produktdaten enthalten fehlende Werte, insbesondere bei Kategorien und beschreibenden Feldern  

---

### 3. Datenbereinigung und Transformation

Bereinigte Tabellen wurden in einem `analytics`-Schema erstellt.

Durchgeführte Transformationen:

- Umwandlung von Zeitstempeln in geeignete `TIMESTAMP`-Typen  
- Konvertierung numerischer Felder (z. B. Preis, Zahlungswerte) in `NUMERIC`  
- Umwandlung ganzzahliger Felder (z. B. Mengen, Dimensionen) in `INT`  
- Korrektur von Inkonsistenzen in Spaltennamen (z. B. `lenght` → `length`)  

Es wurde bewusst keine fachliche Logik oder Imputation (z. B. Ersetzen von `NULL`-Werten) angewendet, um die Integrität der Originaldaten zu erhalten.

---

### 4. Datenvalidierung

Zur Sicherstellung der Datenkonsistenz wurden:

- Zeilenanzahlen zwischen Roh- und bereinigten Tabellen verglichen  
- referenzielle Integrität mittels Orphan-Checks überprüft  

Validierte Beziehungen:

- Bestellungen → Kunden  
- Bestellpositionen → Bestellungen  
- Bestellpositionen → Produkte  
- Zahlungen → Bestellungen  

Nach der Validierung wurden Primär- und Fremdschlüssel definiert, um Konsistenz sicherzustellen und die Performance zu verbessern.

---

## Designentscheidungen

- Rohdaten bleiben unverändert, um Nachvollziehbarkeit sicherzustellen  
- Die Bereinigung konzentriert sich auf Struktur und Datentypen, nicht auf Interpretation  
- Fachliche Logik (z. B. Umgang mit fehlenden Kategorien) wird bewusst in die Analysephase verschoben  
- Referenzielle Integrität wird vor dem Setzen von Constraints explizit überprüft  

---

# Order Value – Analyse & Treiber

### Ziel

Ziel der Analyse war es, den Bestellwert auf Order-Ebene zu definieren und zu verstehen, welche Faktoren hohe Bestellwerte beeinflussen.

Der Bestellwert wurde als Summe aus Produktpreis und Versandkosten pro Bestellung definiert.

---

### 1. Erste Hypothese: Item Count als Treiber

Zunächst wurde untersucht, ob die Anzahl der Artikel pro Bestellung den Bestellwert beeinflusst.

Die Analyse zeigt:

- Der durchschnittliche Bestellwert steigt mit zunehmender Anzahl an Artikeln pro Bestellung deutlich an  
- Dieser Zusammenhang ist insbesondere im Bereich von 1 bis 6 Artikeln stabil beobachtbar  
- Für höhere Item Counts sinkt die Anzahl der Beobachtungen stark, wodurch diese Bereiche nicht belastbar sind  

Zwischenfazit:

Die Ergebnisse legen zunächst nahe, dass größere Warenkörbe der Haupttreiber für hohe Bestellwerte sind.

---

### 2. Einordnung der Verteilung

Eine Betrachtung der Verteilung zeigt jedoch:

- Der Großteil der Bestellungen besteht aus nur einem Artikel  
- Bestellungen mit mehreren Artikeln sind vergleichsweise selten  

Damit basiert der zuvor beobachtete Zusammenhang auf einem kleinen Teil der Daten.

---

### 3. Gegenprüfung: Segmentierung nach Bestellwert

Um zu überprüfen, wodurch hohe Bestellwerte tatsächlich entstehen, wurden Bestellungen nach ihrem Bestellwert segmentiert (niedrig bis hoch).

Die Analyse zeigt:

- Der durchschnittliche Item Count steigt mit zunehmendem Bestellwert nur geringfügig  
- Auch in Segmenten mit hohem Bestellwert dominieren Bestellungen mit wenigen Artikeln  

Schlussfolgerung:

Der Item Count zeigt zwar einen positiven Zusammenhang mit dem Order Value, erklärt jedoch nur einen kleinen Teil der Unterschiede, da die meisten Bestellungen nur ein Item enthalten und auch High-Value-Orders überwiegend aus wenigen Artikeln bestehen.

---

### 4. Zerlegung des Bestellwerts

Zur weiteren Analyse wurde der Bestellwert in seine Bestandteile zerlegt:

- Produktwert  
- Versandkosten  
- Preis pro Artikel  

Dabei zeigt sich:

- Der Produktwert steigt stark mit dem Bestellwert  
- Versandkosten steigen nur moderat und haben einen vergleichsweise geringen Einfluss  
- Der Preis pro Artikel steigt deutlich mit zunehmendem Bestellwert  

---

### 5. Haupterkenntnis

Hohe Bestellwerte werden primär durch höhere Preise pro Artikel und nicht durch größere Warenkörbe oder Versandkosten getrieben.

Der zunächst beobachtete Zusammenhang zwischen Item Count und Bestellwert ist zwar vorhanden, erklärt jedoch nur einen kleinen Teil der Unterschiede und basiert auf einer relativ kleinen Anzahl von Bestellungen mit mehreren Artikeln.

---

### 6. Einordnung

Die Analyse zeigt, dass ein naheliegender Zusammenhang (mehr Artikel → höherer Bestellwert) nicht automatisch einen zentralen Treiber darstellt.

Erst durch die Kombination aus:

- Verteilungsanalyse  
- Segmentierung  
- Zerlegung des Bestellwerts  

wird deutlich, wodurch hohe Bestellwerte tatsächlich entstehen.

---

## Kategorieanalyse: Order Value und High-Value-Verhalten

### Ziel

Ziel dieser Analyse ist es, den Zusammenhang zwischen Produktkategorien und dem Bestellwert (Order Value) zu untersuchen.

Dabei werden zwei Perspektiven kombiniert:

- Niveau des Order Values pro Kategorie
- Anteil von Bestellungen mit besonders hohem Order Value

---

### Methodik

Der Order Value wird definiert als:
> Summe aus `price` und `freight_value` auf Order-Ebene

Eine Kategorie wird einer Bestellung zugeordnet, wenn sie in dieser Bestellung vorkommt.
Bestellungen mit mehreren Kategorien werden entsprechend mehrfach berücksichtigt (pro Kategorie eine Zuordnung).

Für jede Kategorie werden folgende Kennzahlen berechnet:

- durchschnittlicher Order Value (AVG)
- medianer Order Value (Median)
- Differenz zwischen AVG und Median (als Maß für Verzerrung)
- Anteil von High-Value-Orders

High-Value-Orders werden definiert als:
> Bestellungen mit einem Order Value ≥ 75. Perzentil (P75) aller Bestellungen

Zusätzlich werden Kategorien mit geringer Datenbasis ausgeschlossen:
> Es werden nur Kategorien mit mehr als 30 Bestellungen berücksichtigt

Bestellungen ohne zugeordnete Produktkategorie (`NULL`) werden aus der Analyse ausgeschlossen.

---

### Ergebnisse und Interpretation

Die Analyse zeigt deutliche Unterschiede zwischen den Produktkategorien hinsichtlich Order Value, Verteilungsstruktur und Präsenz in High-Value-Orders.

Für die Einordnung wurden vier Fragetypen kombiniert:

- Liegt das Order-Value-Niveau der Kategorie hoch oder eher im mittleren Bereich?
- Ist dieses Niveau stabil oder durch Ausreißer verzerrt?
- Tritt die Kategorie häufig in High-Value-Orders auf?
- Ist sie damit eher ein klarer Treiber, ein Mitläufer in großen Warenkörben oder eine stabile mittlere Kategorie?

--- 

#### 1. Klare High-Value-Kategorien

Eine Kategorie gehört in diese Gruppe, wenn sie gleichzeitig einen hohen durchschnittlichen Order Value, einen hohen Median, eine geringe Differenz zwischen AVG und Median sowie eine hohe High-Value-Quote aufweist. In diesem Fall ist das hohe Niveau nicht nur auf wenige Ausreißer zurückzuführen, sondern zeigt sich auch im typischen Bestellwert.

Ein klares Beispiel ist `pcs`:
> `AVG` = 1286.95</br>
`Median` = 1250.81</br>
`Gap` = 36.14</br>
`High-Value-Quote` = 0.99</br>
`Bestellungen` = 181

Die Kategorie weist mit großem Abstand das höchste Order-Value-Niveau auf. Gleichzeitig liegen Durchschnitt und Median sehr nah beieinander, was für eine stabile Verteilung spricht. Dass 99 % der Bestellungen mit dieser Kategorie zu den High-Value-Orders zählen, zeigt zusätzlich, dass `pcs` fast ausschließlich in hochpreisigen Bestellungen vorkommt. Damit ist `pcs` ein klarer und stabiler High-Value-Treiber.

Auch `portateis_casa_forno_e_cafe` lässt sich dieser Gruppe zuordnen: 
> `AVG` = 669.25</br>
`Median` = 673.47</br>
`Gap` = -4.22</br>
`High-Value-Quote` = 0.67</br>
`Bestellungen` = 75
 
Hier liegen Durchschnitt und Median praktisch auf demselben Niveau. Die Kategorie ist damit außergewöhnlich stabil und zugleich klar mit hohen Order Values verbunden. Zwar ist sie nicht so extrem wie `pcs`, aber von der analytischen Logik her gehört sie ebenfalls zu den klaren High-Value-Kategorien.

--- 

#### 2. Kategorien mit verzerrtem Order Value

Diese Gruppe umfasst Kategorien, deren durchschnittlicher Order Value zunächst hoch wirkt, bei denen der Median jedoch deutlich niedriger liegt. Eine große Differenz zwischen AVG und Median deutet darauf hin, dass der Durchschnitt durch wenige sehr große Bestellungen verzerrt wird und deshalb nicht als verlässlicher typischer Wert gelesen werden sollte.

Ein deutliches Beispiel ist `eletrodomesticos_2`:

> `AVG` = 529.75</br>
`Median` = 283.27</br>
`Gap` = 246.48</br>
`High-Value-Quote` = 0.79</br>
`Bestellungen` = 234

Die Kategorie wirkt auf den ersten Blick stark, weil sowohl der Durchschnitt als auch die High-Value-Quote hoch sind. Der Median liegt jedoch deutlich unter dem Durchschnitt, und die Differenz ist sehr groß. Das spricht dafür, dass `eletrodomesticos_2` zwar häufig in teuren Bestellungen vorkommt, das hohe Niveau aber nicht stabil ist. Entscheidend für die Einordnung ist hier also nicht die hohe Quote, sondern die starke Verzerrung des Durchschnittswerts.

Ein zweites klares Beispiel ist `instrumentos_musicais`: 
> `AVG` = 335.87</br>
`Median` = 145.95</br>
`Gap` = 189.92</br>
`High-Value-Quote` = 0.46</br>
`Bestellungen` = 628
 
Auch hier wirkt der Durchschnitt zunächst relativ hoch. Der Median ist jedoch deutlich niedriger, und die große Differenz zeigt erneut einen starken Ausreißereffekt. Im Unterschied zu `eletrodomesticos_2` ist die High-Value-Quote hier nur mittelmäßig. Die Kategorie ist damit kein stabiler High-Value-Treiber, sondern ein Beispiel dafür, dass ein erhöhter Durchschnittswert allein nicht ausreicht.

---

#### 3. Kategorien als Bestandteil großer Warenkörbe

Diese Gruppe ist analytisch etwas feiner. Gemeint sind Kategorien, deren AVG und Median nicht extrem hoch sind, die aber trotzdem häufig in High-Value-Orders vorkommen. Sie sind damit eher Bestandteil großer Bestellungen als deren eigentlicher Haupttreiber.

Ein gutes Beispiel ist `moveis_quarto`:
> `AVG` = 261.54</br>
`Median` = 239.50</br>
`Gap` = 22.04</br>
`High-Value-Quote` = 0.79</br>
`Bestellungen` = 95
 
Die Kategorie liegt beim Order-Value-Niveau deutlich unter `pcs` oder `portateis_casa_forno_e_cafe`. Gleichzeitig ist die Verteilung sehr stabil, da der Unterschied zwischen Durchschnitt und Median klein ist. Dass die High-Value-Quote dennoch bei 0.79 liegt, zeigt, dass `moveis_quarto` sehr häufig Teil teurer Bestellungen ist, obwohl die Kategorie selbst kein extremes Preisniveau aufweist. Genau deshalb ist sie eher als Bestandteil großer Warenkörbe zu lesen.

Auch `moveis_escritorio` passt in diese Gruppe:
> `AVG` = 270.90</br>
`Median` = 206.84</br>
`Gap` = 64.06</br>
`High-Value-Quote` = 0.63</br>
`Bestellungen` = 1273

Das Order-Value-Niveau ist hier ebenfalls nicht extrem hoch. Die High-Value-Quote ist aber deutlich erhöht, und vor allem die große Fallzahl macht die Kategorie analytisch relevant. `moveis_escritorio` ist damit kein Premium-Treiber wie `pcs`, aber ein wichtiger Bestandteil der allgemeinen Umsatzstruktur und häufig Teil größerer Warenkörbe.

---

#### 4. Stabile, mittelpreisige Kategorien

Diese Gruppe umfasst Kategorien mit mittlerem Order-Value-Niveau, moderater Differenz zwischen AVG und Median und ohne extreme High-Value-Spezialisierung. Sie sind weder klare Treiber noch stark verzerrt, sondern zeigen ein vergleichsweise konsistentes mittleres Bestellverhalten.

Ein passendes Beispiel ist `casa_conforto`:
> `AVG` = 185.13</br>
`Median` = 140.06<br>
`Gap` = 45.07</br>
`High-Value-Quote` = 0.45</br>
`Bestellungen` = 397
 
Die Kategorie liegt im Vergleich zum restlichen Ranking auf einem mittleren Niveau. Die Differenz zwischen Durchschnitt und Median ist vorhanden, aber nicht groß genug, um von starker Verzerrung zu sprechen. Auch die High-Value-Quote liegt im mittleren Bereich. Damit eignet sich `casa_conforto` gut als Beispiel für eine stabile, mittelpreisige Kategorie ohne extreme Ausprägung in eine Richtung.

---

### Zentrale Erkenntnis

Die Analyse zeigt, dass ein hoher durchschnittlicher Order Value allein nicht ausreicht, um die Relevanz einer Kategorie zu bewerten.

Erst durch die Kombination aus:
- Durchschnitt (AVG)
- Median
- Differenz zwischen AVG und Median
- Anteil an High-Value-Orders

lässt sich unterscheiden zwischen:
- tatsächlich werttreibenden Kategorien,
- Kategorien mit verzerrten Durchschnittswerten,
- Kategorien, die häufig Teil großer Bestellungen sind,
- und stabilen Kategorien mit mittlerem Order-Value-Niveau.
 
Gerade diese Kombination macht sichtbar, dass Kategorien mit ähnlichem Durchschnittswert analytisch sehr unterschiedliche Rollen im Bestellverhalten einnehmen können.

## Gesamtfazit: Treiber des Order Value

Die Analyse zeigt, dass der Order Value durch unterschiedliche Faktoren beeinflusst wird, deren Wirkung sich deutlich unterscheidet.

Zunächst legt die Betrachtung des Item Counts nahe, dass Bestellungen mit mehr Artikeln höhere Bestellwerte aufweisen. Dieser Zusammenhang ist jedoch nur eingeschränkt relevant, da der Großteil der Bestellungen nur aus einem Artikel besteht und auch in hochpreisigen Segmenten überwiegend wenige Artikel pro Bestellung enthalten sind.

Eine weiterführende Analyse zeigt, dass der Order Value primär durch den Preis pro Artikel bestimmt wird. Höhere Bestellwerte entstehen somit nicht durch größere Warenkörbe, sondern durch teurere Einzelprodukte.

Die Kategorieanalyse ergänzt dieses Bild: Bestimmte Produktkategorien treten systematisch in Bestellungen mit hohem Order Value auf, unterscheiden sich jedoch stark in ihrer Stabilität und Verteilung. Während einige Kategorien konsistent hohe Bestellwerte aufweisen, sind andere durch einzelne große Bestellungen verzerrt oder treten lediglich als Bestandteil größerer Warenkörbe auf.

Insgesamt zeigt sich, dass hohe Bestellwerte nicht durch einen einzelnen Faktor erklärt werden können. Erst durch die Kombination aus strukturellen Merkmalen (Item Count) und inhaltlichen Merkmalen (Produktkategorie) wird deutlich, wodurch sich Unterschiede im Order Value tatsächlich ergeben.