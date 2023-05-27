## Déroulement du vote

### Voici le déroulement de l'ensemble du processus de vote :

- L'administrateur du vote enregistre une liste blanche d'électeurs identifiés par leur adresse Ethereum.
- L'administrateur du vote commence la session d'enregistrement de la proposition.
- Les électeurs inscrits sont autorisés à enregistrer leurs propositions pendant que la session d'enregistrement est active.
- L'administrateur de vote met fin à la session d'enregistrement des propositions.
- L'administrateur du vote commence la session de vote.
- Les électeurs inscrits votent pour leur proposition préférée.
- L'administrateur du vote met fin à la session de vote.
- L'administrateur du vote comptabilise les votes.
- Tout le monde peut vérifier les derniers détails de la proposition gagnante.

### Notes sur le déroulement du processus de vote (étapes du workflow)
- L'étape initiale du vote (contract) est *RegisteringVoters*
- L'administrateur fait évoluer le déroulement du vote à partir de la fonction *nextStatus()* dans l'interface de **Remix**
- L'étape (ID) du déroulement du vote est consultable par tous via *getCurrentStatus()* et *getCurrentStatusDescription()* dans l'interface de **Remix**
- Dès que l'administrateur passe à l'étape *VotesTallied* le décompte des votes est éffectué et le résultat est accessible via l'appel à *getWinner()* dans l'interface de **Remix**
- La première proposition rencontrée qui remporte le plus de voix l'emporte, l'algorithme ne gère pas les cas d'égalité

### Concernant l'administrateur
- C'est l'administrateur qui déploie le contrat dans l'interface de **Remix**
- C'est l'administrateur qui enregistre les électeurs dans **Remix**
- Afin de séparer les fonctions, un administrateur de par son status **n'est pas** un électeur et ne peut donc voter, simplement en l'état
- Si l'administrateur veut voter, il doit se créer un compte d'électeur ou s'enregistrer en tant qu'électeur...
- C'est l'administrateur qui fait évoluer les étapes du déroulement du vote, par l'usage de la fonction *nextStatus()* dans l'interface de **Remix**.

#### Les étapes du déroulement du vote sont les suivantes :

| WorkflowStatus               | Descriptions                 |
| ---------------------------- | ---------------------------- |
| RegisteringVoters            | Enregistrement des électeurs |
| ProposalsRegistrationStarted | On récolte les propositions  |
| ProposalsRegistrationEnded   | On clos les propositions     |
| VotingSessionStarted         | Le vote est commencé         |
| VotingSessionEnded           | Le vote est clos             |
| VotesTallied                 | Le dépouillement est fait    |

## Usage des fonctionalités du contrat

### Utilisable en fonction du déroulement du vote (WorkflowStatus)

| WorkflowStatus               | Fonctions       |
| ---------------------------- | --------------- |
| RegisteringVoters            | *addVoter()*    |
| ProposalsRegistrationStarted | *addProposal()* |
| ProposalsRegistrationEnded   |                 |
| VotingSessionStarted         | *vote()*        |
| VotingSessionEnded           |                 |
| VotesTallied                 | *getWinner()*   |

### Utilisable uniquement par l'administrateur :

```javascript
addVoter()
nextStatus()
notRegistred()
```

### Utilisable par tous électeur autorisé lors de la session de vote :
```javascript
addProposal()
```

### Utilisable par tous électeur autorisé en permanance :
```javascript
seeVoters()
seeProposals()
```

### Utilisable par tous en permanence :
```javascript
getCurrentStatusId()
getCurrentStatusDescription()
```

### Les comptes

| Compte                    | Addr...                                        |
| ------------------------- | ---------------------------------------------- |
| **Administrateur**        | **0x5B38Da6a701c568545dCfcB03FcB875f56beddC4** |
| Votant 1                  | 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2     |
| Votant 2                  | 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db     |
| Votant 3                  | 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB     |
| Votant 4                  | 0x617F2E2fD72FD9D5503197092aC168c91465E7f2     |
| Votant 5                  | 0x17F6AD8Ef982297579C203069C1DbfFE4348c372     |
| Votant 6                  | 0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678     |
| Votant 7                  | 0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7     |
| *Votants non enregistrés* | *autres adresses*                              |

### Exemple de scénario de test/d'usage

**Déploiement par l'administrateur**
- [X] L'administrateur essaie d'obtenir le status du déroulement et obtient "RegisteringVoters" (*getCurrentStatusId* & *getCurrentStatusDescription*)
- [X] L'administrateur enregistre les **7 électeurs** (*voir plus haut*)
- [X] L'administrateur essaie de voir la liste des votants **en vain** !
- [X] Le votant 1 essaie de visualiser la liste des votants
- [X] L'admin essaie d'obtenir le résultat du vote **en vain**
- [X] Le votant 1 essaie d'obtenir le résultat du vote **en vain**
- [X] Le votant 5 essaie d'obtenir le résultat du vote **en vain**
- [X] Le votant 7 essaie de changer l'état du workflow **en vain** !

**NEXT : ProposalsRegistrationStarted, index : [1]**
- [X] Un votant non enregistré essaie de faire une proposition, **en vain** !
- [X] Un votant non enregistré essaie de visualiser les propositions, **en vain** !
- [X] votant 1, essaie de voter **en vain**
- [X] votant 2, essaie de voter **en vain**
- [X] votant 7, essaie de voter **en vain**
- [X] Le votant 5 essaie d'obtenir le résultat du vote **en vain** !
- [X] Le votant 1 fait la "proposition 1", index : [0]
- [X] Le votant 1 visualise les propostions, ok
- [X] Le votant 3 visualise les propostions, ok
- [X] Le votant 3 fait la "proposition 3", index : [1]
- [X] Le votant 3 fait la "proposition 3 bis", index : [2]
- [X] Le votant 5 visualise les propostions, ok
- [X] Le votant 5 essaie d'obtenir le résultat du vote **en vain** !

**NEXT : ProposalsRegistrationEnded, index : [2]**
- [X] Le votant 5 essaie d'obtenir le résultat du vote **en vain** !
- [X] votant 7, essaie de voter **en vain** !

**NEXT : VotingSessionStarted, index : [3]**
- [X] Un votant non enregistré essaie de voter, **en vain** !
- [X] Le votant 5 fait la "proposition 5" **en vain**
- [X] Le votant 1 vote pour la propostion "proposition 1", index : [0]
- [X] Le votant 1 re vote pour la propostion "proposition 1", index : [0] **en vain** !
- [X] Le votant 3 vote pour la propostion "proposition 3", index : [1]
- [X] Le votant 3 vote pour la propostion "proposition 3", index : [1] **en vain** !
- [X] Le votant 4 vote pour la propostion "proposition 3", index : [1]
- [X] Le votant 6 vote pour la propostion "proposition 1", index : [0]
- [X] Le votant 6 vote pour la propostion "proposition 3", index : [1] **en vain** !
- [X] Le votant 7 vote pour la propostion "proposition 1", index : [0]
- [X] Le votant 7 visualise les propositions
- [X] Le votant 7 visualise les votants

**NEXT : VotingSessionEnded, index : [4]**
- [X] Le votant 7 vote pour la propostion "proposition 1", index : [0] **en vain** !
- [X] Le votant 5 essaie d'obtenir le résultat du vote **en vain** !
- [X] Le votant 5 fait la "proposition 5" **en vain** !

**NEXT : VotesTallied, index : [5]**
- [X] Tous les votant obtiennent le résultat du vote (nom de la proposition) !
- [X] Le votant 5 fait la "proposition 5" **en vain** !
- [X] Le votant 7 vote pour la propostion "proposition 1", index : [0] **en vain** !

### Exemple de scénario de test/d'usage pour whitelist/blacklist

**Déploiement par l'administrateur**
- [X] L'administrateur essaie d'obtenir le status du déroulement et obtient "RegisteringVoters" (*getCurrentStatusId* & *getCurrentStatusDescription*)
- [X] L'administrateur enregistre les **2 électeurs** (*voir plus haut*)
- [X] L'administrateur essaie de voir la liste des votants **en vain** !
- [X] Le votant 1 essaie de visualiser la liste des votants
- [X] L'administrateur blacklist l'électeur 1
- [X] Le votant 1 essaie de visualiser la liste des votants **en vain** !
- [X] L'administrateur whitelist l'électeur 1
- [X] Le votant 1 essaie de visualiser la liste des votants


