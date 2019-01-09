# boipxe
Chainload iPXE for BlueOcean infrastructure

iPXE działa w warstwie 2  ISO/OSI na określonym VLAN-ie, w tym celu w Docker-ze należy utworzyć odpowiednią sieć dla wymaganego VLAN-u.
Przykładowo jeśli VLAN na którym chcemy świadczyć usługi iPXE to 479 i jest zakończony na interfejsie bond0, oraz chcemy by działająca na nim sieć nosiłą nazwę PXE_core.

docker network create -d macvlan --subnet 10.100.0.0/24 --gateway=10.100.0.1 -o parent=bond0.479 PXE_core

Komenda uruchomienia kontenera w tym wypadku to:
docker run -dt --network PXE_core -v /srv/tftp:/srv/templetes --name boipxe bockpl/boipxe

gdzie:
   -v /srv/tftp:/srv/templetes - to mapowanie katalogu serwowanego przez http w celu zdalnego bootowania
