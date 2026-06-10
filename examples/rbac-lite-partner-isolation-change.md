# Muutospyyntö — RBAC-Lite partner isolation governance example

## Perustiedot

- **Muutoksen nimi:** RBAC-Lite partner isolation governance example
- **Pyytäjä:** Jonne Silvennoinen
- **Päivämäärä:** 2026-06-10
- **Riskiluokka:** 2
- **Kohdeympäristö:** documentation

## Kuvaus

Tämä muutospyyntö kuvaa RBAC-Lite partner isolation -muutoksen governance- ja dokumentaatioesimerkkinä. Muutos ei muuta tuotantokoodia, tenant isolation -logiikkaa, partner-suodatusta tai WordPress-käyttöoikeuksia.

## Vaikutusanalyysi

Vaikutus kohdistuu dokumentaatioon ja compliance-validointiin. Tuotantoympäristöön, käyttäjädataan, partner-eristykseen, audit log -tauluihin tai NDA enforcement -logiikkaan ei tehdä muutoksia.

## Rollback-suunnitelma

Muutoksen voi palauttaa poistamalla tai revert-toiminnolla kumoamalla tämän esimerkkitiedoston ja siihen liittyvän workflow-viittauksen.

## Testaussuunnitelma

- Aja legacy validator tätä tiedostoa vasten.
- Varmista, että Riskiluokka 2 tunnistetaan oikein.
- Varmista, että hyväksyjiä on 2/2.
- Varmista, ettei validaattori raportoi virheitä.

## Hyväksyjät

- Jonne Silvennoinen
- Gatehouse reviewer
