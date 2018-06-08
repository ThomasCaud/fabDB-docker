# fabDB-docker

## Prérequis :
Il faut avoir un fichier **parameters.yml** dans le répertoire du Dockerfile, avec les bons identifiants de BDD, avant de lancer le build.

## Commandes :
Pour build **l'image** *fabdb-apache-php* :

    docker build -t fabdb-apache-php . --no-cache --network="host"

Pour lancer le **container** :
	
    docker stop apache-php;
	docker rm apache-php;
	docker run -d --name=apache-php -v /fabdb-src/var --net="host" fabdb-apache-php;
	docker logs -f apache-php;


