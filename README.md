# DEVWKS-1407 - Utilizing Cisco CXTA service framework to validate network elements

Repository which contains documentation and material for CiscoLive Europe 2020 Devnet Workshop

## Bringing up the environment

Run `start-routers.sh` to

- Start the VMs through `vagrant up`
- Perform some initial configuration (especially the router's hostname, but also some interface and routing config)
- generate a `testbed.yaml` taking the vagrant ssh configuration
- start the cxta_devnet docker container through docker-compose
- Run a robot test 

## Connecting to the container

```
docker exec -it cxta_devnet bash
```

## CXTA Documentation

Visit <http://127.0.0.1:8081> from your local browser to check the CXTA library documentation.  
The list of keywords is available through <http://127.0.0.1:8081/libdoc/keyword-index/>.

## Bring down the environment

Run 

```
vagrant halt -f
docker-compose down
```



