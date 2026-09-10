# I1 — Process Model / BPMN-like flow

## Portée

Ce diagramme représente le processus métier de référence. Il est volontairement versionnable en Markdown/Mermaid. Une exportation BPMN 2.0 native pourra être ajoutée quand l'outil de modélisation choisi sera utilisé.

```mermaid
flowchart LR
  subgraph C[Customer]
    C1[Signale paiement non reçu]
    C2[Fournit informations]
    C3[Reçoit résultat]
  end

  subgraph CS[Customer Service]
    A1[Identifier / authentifier]
    A2[Ouvrir Customer 360]
    A3[Créer Interaction]
    A4[Créer PAYMENT_NOT_RECEIVED]
    A5[Informer client]
  end

  subgraph P[Pega Case Management]
    P1[Lire statut paiement]
    G1{Statut ?}
    P2[Créer / corréler PAYMENT_UNKNOWN]
    P3[Router Payment Ops]
    P4[Collecter evidence]
    G2{Fraude ?}
    P5[Créer / référencer FRAUD_REVIEW]
    P6[Décision déterministe]
    G3{Approbation requise ?}
    P7[Human approval]
    P8[Soumettre Resolution Command]
    P9[Attendre / vérifier outcome]
    G4{Outcome déterministe ?}
    P10[Résoudre et clôturer]
    P11[WAITING_EXTERNAL / TECHNICAL_BLOCKED]
  end

  subgraph CORE[Payment Core / Decision services]
    X1[Payment Read API]
    X2[Rules / ODM]
    X3[Payment Resolution API]
    X4[Outcome event / response]
  end

  C1 --> A1 --> A2 --> A3 --> A4 --> P1 --> X1 --> G1
  G1 -- COMPLETED/REJECTED --> A5 --> C3
  G1 -- UNKNOWN --> P2 --> P3 --> P4 --> G2
  G2 -- yes --> P5 --> P6
  G2 -- no --> P6
  P6 --> X2 --> G3
  G3 -- yes --> P7 --> P8
  G3 -- no --> P8
  P8 --> X3 --> P9 --> X4 --> G4
  G4 -- yes --> P10 --> A5 --> C3
  G4 -- no --> P11 --> P4
  C2 --> P4
```

## Événements de début

- interaction client ;
- événement `PaymentUnknownDetected` ;
- détection de divergence de réconciliation ;
- remontée de risque fraude.

## Événements intermédiaires

- réponse Payment Read ;
- evidence reçue ;
- approbation terminée ;
- callback/outcome ;
- timer SLA ;
- timeout technique.

## Événements de fin

- demande expliquée sans investigation ;
- investigation résolue et confirmée ;
- dossier annulé avec motif ;
- dossier dupliqué et rattaché au Case canonique.

## Règles de modélisation

- un timeout n'est pas un résultat financier ;
- un appel synchrone est réservé aux lectures/commandes ayant besoin d'une réponse immédiate ;
- l'attente longue doit être modélisée comme état de Case, pas comme thread bloqué ;
- les décisions sensibles sont explicites et auditables ;
- la fermeture exige un outcome déterministe ou une justification métier documentée.

**Statut : DESIGNED — I1.**