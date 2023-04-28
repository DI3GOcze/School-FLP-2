# FLP logický projekt - Turingův stroj

Autor: Jakub Kryštůfek

Login: xkryst02

Akademický rok: 2022/2023

Název zadání: Turingův stroj

## Návod k použití

### Překlad
Projekt lze přeložit pomocí příkazu `make`, který vytvoří spustitelný soubor `flp22-log`. Projekt je překládán pomocí [SWI-Prolog](https://www.swi-prolog.org/).

### Spuštění
Program nepřijímá žádné parametry, pouze očekává reakci ze standardního vstupu. Spustit lze tedy pomocí:
```bash
$ ./flp22-log < input.txt > output.txt
```

## Popis řešení

### Interní reprezentace dat 
Přechodová pravidla Turingova stroje jsou reprezentována jako dynamický predikát `ts_rule/4`, zatímco obsah pásky je reprezentován seznamem znaků, který je předáván z jednoho výpočetního kroku na následující. Interní páska zároveň obsahuje reprezentaci aktuálního stavu (jeho pozice udává pozici čtecí hlavy), tedy interní obsah iniciální pásky pro vstup `abc` = `['S', 'a', 'b', 'c']`.

### Postup výpočtu

#### Zpracování dat ze standardního vstupu
Program nejprve nahraje veškerý obsah STDIN do jednotlivých řádků a následně tyto řádky zpracuje a adekvátně uloží přechodová pravidla Turingova stroje a vytvoří iniciální stav pásky.

#### Simulace Turingova stroje
Po zpracování vstupu a úspěšné inicializaci se spustí simulace Turingova stroje, která je implementovaná predikátem `run_ts/2`. Tento predikát představuje jeden výpočetní krok Turingova stroje, který představuje:

1. Kontrola, zdali aktuální konfigurace turingova stroje nebyla již v minulosti použita. Tato kontrola dokáže odhalit některé případy nekonečného cyklu. Pro uchovávání použitých konfigurací se využívá dynamický predikát `used_configuration/1`.
2. Zjištění aktuálního stavu a znaku pod čtecí hlavou. To jde zjistit z interní reprezentace pásky, která obsahuje aktuální stav a znak následující za aktuálním stavem odpovídá znaku pod čtecí hlavou.
3. Zjištění aplikovatelného pravidla pomocí predikátu `ts_tule/4`. Díky využití dynamického predikátu je vždy nalezeno jedno aplikovatelné pravidlo, a pokud někde v budoucnu výpočet selže, je pomocí backtrackingu nalezeno jiné aplikovatelné pravidlo a výpočet se spouští znovu s ním. Díky této skutečnosti je simulace nedeterministická.
4. Aplikace nalezeného pravidla na aktuální pásku. To vytvoří pásku novou, která je předána nadcházejícímu výpočetnímu kroku.
5. Opakuje se volání výpočetního kroku s nově vytvořenou páskou.

## Spuštění ukázkových vstupů

Veškeré ukázkové vstupy jsou uloženy v adresáři `/examples`. Pro každý vstup `*.in` je také odpovídající výstup `*.out`.

### 1. Ukázka ze zadání
Ukázkový příklad ze zadání. Délka výpočtu `0.017s`  Spuštění pomocí:
```bash
$ ./flp22-log < examples/task.in
```

### 2. Převod znaků `'a'` na `'b'`
Příklad, který převede veškeré znaky `'a'` na znaky `'b'` v řetězci `"aadcacbcaba"`. Délka výpočtu `0.017s`. Spuštění pomocí:
```bash
$ ./flp22-log < examples/a_to_b.in
```

### 3. Duplikace řetězce
Příklad, který zduplikuje vstupní řetězec `"aababaaabbbababbbabaabbbabababbb"` oddělený mezerou na `"aababaaabbbababbbabaabbbabababbb aababaaabbbababbbabaabbbabababbb"` . Délka výpočtu `0.574s`. Spuštění pomocí:
```bash
$ ./flp22-log < examples/copy.in
```

### 4. Funkční ukázka nedeterminizmu
Příklad, který ukazuje funkčnost nedeterminizmu v mém řešení. Jedná se o velice jednoduchý příklad se dvěma pravidly, které jsou obě aplikovatelné hned při prvním kroku výpočtu, avšak první pravidlo vede k selhání a až druhé vede k úspěšnému výpočtu. Při výpočtu se nejprve aplikuje první pravidlo a následně po selhání se backtrackuje na druhé aplikovatelné pravidlo, které vede k úspěchu. Délka výpočtu `0.018s`. Spuštění pomocí:
```bash
$ ./flp22-log < examples/nondeterm-succ.in
```

### 4. Ukázka chyby nedeterminismu
Jak zmiňuji v sekci omezení, tak má simulace se zacyklí, pokud se některá z nedeterministických větví zacyklí a cyklus se nedetekuje. Tato nedokonalost je právě ukázána v tomto příkladě. Jako v minulém příkladě se jedná o Turingův stroj se 3 pravidly, kde jsou první a poslední aplikovatelná hned v prvním výpočetním kroku. První a druhé pravidlo však vede k nekonečnému cyklu a poslední pravidlo vede k úspěchu. Jelikož na aplikaci posledního pravidla nikdy nedojde, zůstane simulace v nekonečném cyklu. Délka výpočtu `infinity`. Spuštění pomocí:
```bash
$ ./flp22-log < examples/nondeterm-fail.in
```

### 5. Ukázka detekce nekonečného cyklu
Mé řešení dokáže detekovat takové cyklení turingova stroje, kde se stroj vyskytne v nějaké konfiguraci vícekrát. Pokud se Turingův stroj dvakrát dostane do stejné konfigurace (stejný obsah pásky, pozice hlavy a stav), pak je jasné, že se nachází v nekonečném cyklu. Detekci takového cyklu prezentuje právě tento příklad, kde jsou pouze dvě pravidla. První zapříčiní nekonečný cyklus a druhý vede k úspěchu. Stroj detekuje opakovanou konfiguraci a pak násladně pomocí backtrackingu vyzkouší druhé pravidlo, které poté vede k úspěchu. Délka výpočtu `0.018s`. Spuštění pomocí:
```bash
$ ./flp22-log < examples/infinite-detect.in
```

## Omezení
Jediné omezení, které je mi známo u mého řešení je případ, kdy dojde k nedetekovatelnému zacyklení stroje v jedné z nedeterministických větvích výpočtu. Toto chování je ukázáno v ukázkovém příkladu `examples/nondeterm-fail.in`. Samotný nedeterminismus a detekce opakovaných konfigurací jsou funkční, což je potvrzeno ukázkovými příklady `examples/nondeterm-succ.in` a `examples/infinite-detect.in`. Pro řešení toho nedostatku bych navrhoval iterativně krokovat všechny výpočetní větve, takže pokud všechny větve cyklí, ale jedna vede k výsledku, tak se k tomuto výsledku vždy dojde.