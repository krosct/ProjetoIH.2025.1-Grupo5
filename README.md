# ProjetoIH.2025.1-Grupo5

## Criando projeto ModelSim

Crie um projeto no folder default do ModelSim, mantenha todas as opções default.
Agora basta compilar

## Trabalhando com branches
Ao iniciar o desenvolvimento de uma nova feature, utilizar os comandos, partindo da branch main, por exemplo:

`git checkout -b feat/multiplicador`

Caso adições sejam integradas na main enquanto você desenvolve, faça, a partir da sua branch feature:

`git checkout main
git pull
git checkout [sua-feature-branch]
git merge`
