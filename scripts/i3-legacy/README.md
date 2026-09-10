# I3 legacy — collecte de preuves Pega 8.4 Personal Edition

Ce dossier ne contient aucun binaire Pega. Il sert uniquement à auditer localement une installation historique déjà détenue par l'opérateur.

## Usage

Par défaut le script cherche :

```text
C:\workspaces\paga\116674_PE8.4.0\PRPC_PE\PersonalEdition
```

Exécution :

```powershell
powershell -ExecutionPolicy Bypass -File scripts\i3-legacy\collect-pe84-evidence.ps1
```

Pour auditer une autre copie, notamment l'installation utilisée sous `C:\workspaces\paga\PersonalEdition` :

```powershell
powershell -ExecutionPolicy Bypass -File scripts\i3-legacy\collect-pe84-evidence.ps1 `
  -Pe84Root 'C:\workspaces\paga\PersonalEdition'
```

## Ce que le script collecte

- chemin audité ;
- version Java/JRE ;
- version Tomcat ;
- version PostgreSQL ;
- taille + SHA-256 de `prweb.war`, `prhelp.war` et du driver JDBC s'ils existent ;
- présence et nombre de fichiers dans `tomcat\webapps\prweb` ;
- présence de `server.xml`, `context.xml`, `catalina.properties` et `web.xml` ;
- ports TCP locaux 8080/5432 ;
- test HTTP local non authentifié.

Aucun contenu de fichier de configuration, mot de passe, certificat ou dump n'est collecté automatiquement.

## Résultat

Les preuves sont placées sous :

```text
evidence/runtime/pe84-local/<timestamp>/
```

Les sorties doivent être relues avant commit. Ne jamais versionner de secret ni de binaire Pega.

## Critère de validation

Une réponse HTTP seule ne suffit pas. Le statut `RUNTIME VALIDATED` nécessite également un démarrage correct de la base et une connexion Pega réellement effectuée par l'opérateur.
