# Muutospyyntö — RBAC-Lite partner isolation governance example

## Perustiedot

- **Muutoksen nimi:** RBAC-Lite partner isolation governance example
- **Pyytäjä:** Jonne Silvennoinen
- **Päivämäärä:** 2026-06-10
- **Riskiluokka:** 2
- **Riskiluokan perustelu:** Muutos koskee RBAC-Lite partner isolation -toiminnon governance- ja dokumentaatioesimerkkiä. Muutos liittyy access management -kontrolleihin, mutta ei muuta tuotantokoodia, tenant isolation -logiikkaa tai käyttäjäoikeuksia.
- **Kohdeympäristö:** staging
- **Testausympäristö:** staging

### Riskiluokan perustelu
Riskiluokka 2 on valittu, koska muutos koskee RBAC-Lite partner isolation -toiminnon governance- ja dokumentaatioesimerkkiä. Muutos liittyy access management -kontrolleihin ja compliance-validointiin, mutta ei muuta tuotantokoodia, tenant isolation -logiikkaa, partner-suodatusta, WordPress-käyttöoikeuksia tai käyttäjädataa.

## Kuvaus

Tämä muutospyyntö kuvaa RBAC-Lite partner isolation -muutoksen governance- ja dokumentaatioesimerkkinä. Muutos ei muuta tuotantokoodia, tenant isolation -logiikkaa, partner-suodatusta tai WordPress-käyttöoikeuksia.

## Vaikutusanalyysi

Vaikutus kohdistuu dokumentaatioon ja compliance-validointiin. Tuotantoympäristöön, käyttäjädataan, partner-eristykseen, audit log -tauluihin tai NDA enforcement -logiikkaan ei tehdä muutoksia.

## Palautussuunnitelma

- **Palautusstrategia:** Muutoksen voi palauttaa poistamalla tämän esimerkkitiedoston tai revert-toiminnolla kumoamalla tähän tiedostoon ja workflow-polkuun tehdyt muutokset.
- **Rollback-vastuu:** Jonne Silvennoinen
- **Palautuksen arvioitu kesto:** 5 minuuttia

## Testaussuunnitelma

- Aja legacy validator tätä tiedostoa vasten.
- Aja modular CLI validator tätä tiedostoa vasten.
- Varmista, että Riskiluokka 2 tunnistetaan oikein.
- Varmista, että hyväksyjiä on 2/2.
- Varmista, ettei validaattori raportoi virheitä.

## Hyväksyjät

- **Hyväksyjä 1:** Jonne Silvennoinen
- **Hyväksyjä 2:** Gatehouse reviewer
