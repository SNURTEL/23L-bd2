31.03.2023 15:45
Z: SEM4/BD2/ **BD2 projekt wymagania**
Tagi:  

# Wypożyczalnia samochodów miejskich (elektrycznych, hybrydowych, spalinowych)

## Etap 0: Opis słowny projektu (20%) do 31.03.2023 r. (dokument)
- słowny opis przyjętych założeń rozwiązywanego zadania,
- model pojęciowy (diagram E-R z graficznym opisem związków i opisem atrybutów: typ danych, dziedzina, ograniczenia, opis),
- rozmiar zadania ok.15-20 encji

---
- ==Samochody==
	- ==*encja lokalizacja*==
	- ==Model== (encja słownikowa)
		- ==marka==
		- ==typ==
		- silnik
		- napęd
		- skrzynia
		- miejsca
	- wymagana kat. prawa jazdy
	- paliwo / akumulator
	- stan techniczny
	- ==kontrola techniczna==
	- ==ubezpieczenie==
	- ==dowód rejestracyjny==
- ==Wypożyczenia==
	- stan 
	- jaki samochód
	- kto 
	- stawka
	- od kiedy
	- do kiedy
	- ==Faktura==
- ==Użytkownicy==
	- ==Prawo jazdy==
	- Osoby prywatne 
 - ==Pracownicy==
	 - ==Mechanik==
	 - ==Admin==
- ==Log wypożyczeń==

## Etap 1: Projekt bazy danych (20 %) do 21.04.2023 r. (dokument)
- analiza wymagań funkcjonalnych,
- analiza wymagań pozafunkcjonalnych,
- opis przyjętych założeń projektowych oraz uściśleń słownego opisu zadania (w tym wybór technologii) ,
- logiczny model danych (diagram logiczny).

- FK w inspections
- redundancja na fakturach (customers i rental order)

> Celem naszego projektu jest rozwiązanie problemu związanego z wypożyczaniem samochodów miejskich. Wypożyczalnia będzie przechowywać informacje na temat samochodów, np. marka, model, informacje związane ze stanem technicznym, w tym daty kontroli i ewentualne problemy z pojazdem. Użytkownik, wprowadzając swoje prawo jazdy do systemu, będzie mógł wypożyczyć samochód na określony czas, jako osoba prywatna lub "na firmę". Po zakończeniu wypożyczenia, aktualne współrzędne samochodu zostaną zaktualizowane w bazie danych, aby zapisać miejsce, w którym został zaparkowany przez użytkownika. Baza danych będzie również zawierać informacje o pracownikach oraz ich stanowiskach, aby precyzyjnie określić, za co są odpowiedzialni.

### Wymagania funkcjonalne
- Możliwości użytkownika:
	- Wyszukiwanie samochodów wg kryteriów:
		- Typ (w tym prawo jazdy)
		- Odległość od użytkownika
		- Cena
		- Miejsca
		- Skrzynia
	- Wypożyczanie
	- Utworzenie konta
		- Modyfikacje danych
- Możliwości administratora:
	- Zarządzanie użytkownikami
	- Zarządzanie pojazdami
		- W tym ustawianie dostępności
		- W tym dodawanie / usuwanie samochodów z systemu
	- Zarządzanie historią wypożyczeń
- Możliwości mechanika
	- Wprowadzanie przeglądów do systemu
	- Ustawianie stanu technicznego pojazdów

### Wymagania niefunkcjonalne
(Dostęp do aplikacji klienckiej z różnych urządzeń)
1. Możliwość wyszukiwania samochodów przez użytkownika:
- Użytkownik powinien mieć możliwość wyszukiwania samochodów według kryteriów takich jak:
    - Typ samochodu, w tym wymagany typ prawa jazdy
    - Odległość od użytkownika
    - Cena
    - Liczba miejsc w samochodzie
    - Rodzaj skrzyni biegów
- System powinien zwracać listę samochodów spełniających wybrane kryteria wyszukiwania.

2. Możliwość wypożyczenia samochodu przez użytkownika:
- Użytkownik powinien mieć możliwość wypożyczenia wybranego samochodu.
- System powinien wyświetlać informacje dotyczące terminu wypożyczenia oraz kosztów.

3. Możliwość utworzenia konta i modyfikacji danych przez użytkownika:
- Użytkownik powinien mieć możliwość utworzenia konta w systemie oraz modyfikacji swoich danych.
- System powinien umożliwiać modyfikację danych takich jak imię, nazwisko, adres e-mail oraz hasło.

4. Możliwość zarządzania użytkownikami przez administratora:
- Administrator powinien mieć możliwość zarządzania użytkownikami systemu, w tym m.in. dodawania nowych użytkowników, edycji danych użytkowników oraz usuwania użytkowników z systemu.

5. Możliwość zarządzania pojazdami przez administratora:
- Administrator powinien mieć możliwość zarządzania pojazdami w systemie, w tym m.in. ustawiania dostępności poszczególnych samochodów, dodawania nowych samochodów do systemu oraz usuwania samochodów z systemu.

6. Możliwość zarządzania historią wypożyczeń przez administratora:
- Administrator powinien mieć możliwość zarządzania historią wypożyczeń samochodów, w tym m.in. przeglądania historii wypożyczeń, usuwania wypożyczeń z historii oraz dodawania nowych wpisów do historii.

7. Możliwość wprowadzania przeglądów do systemu oraz ustawianie stanu technicznego pojazdów przez mechanika:
- Mechanik powinien mieć możliwość wprowadzania przeglądów technicznych pojazdów do systemu oraz ustawiania stanu technicznego poszczególnych samochodów.
- System powinien umożliwiać wprowadzenie informacji takich jak data ostatniego przeglądu, data kolejnego przeglądu oraz informacje o stanie technicznym pojazdu.

#### Wybór technologii i uściślenie założeń projektowych
Bazę danych postawimy na Infinite Free, używając silnika MySQL. Aplikacja zostanie napisana używająć framework'a "Flutter" i języka "Dart"

## Etap 2: Projekt Aplikacji (dostępowej i raportowej, 30%) do 19.05.2023 r. (termin zgłoszenia gotowości do prezentacji).
- fizyczny model danych, - dokument
- implementacja bazy danych, - prezentacja na konsultacjach (tabele, ograniczenia, wyzwalacze)
- wygenerowanie danych testowych (dla testów wymagań funkcjonalnych i pozafunkcjonalnych) - prezentacja
- scenariusze testów. - dokument

### Fizyczny model danych
![](https://gitlab-stud.elka.pw.edu.pl/towienko/23l-bd2-projekt/-/raw/master/script/diagram.png)

### Implementacja bazy danych (skrypty)
Folder 'script'

### Wygenerowanie danych testowych
Folder 'script/generate-data'

### Scenariusze testów
[Plik pdf](<link>)