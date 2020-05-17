Task:

Descripton:

    Demo Flask production docker image on kubernetes.

Working:

    $ docker build -t m8ndevops/flask:latest .

    $ docker push m8ndevops/flask:latest

    $ kubectl apply -f deploy.yml
