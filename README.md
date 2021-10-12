[![Build Status](https://drone.p.lodz.pl/api/badges/seweryn.sitarski@p.lodz.pl/boipxe/status.svg)](https://drone.p.lodz.pl/seweryn.sitarski@p.lodz.pl/boipxe)


# boipxe
Chainload iPXE for BlueOcean infrastructure

iPXE działa w warstwie 2  ISO/OSI na określonym VLAN-ie, w tym celu w Docker-ze należy utworzyć odpowiednią sieć dla wymaganego VLAN-u.
Przykładowo jeśli VLAN na którym chcemy świadczyć usługi iPXE to 479 i jest zakończony na interfejsie bond0, oraz chcemy by działająca na nim sieć nosiłą nazwę PXE_core.

docker network create -d macvlan --subnet 10.100.0.0/24 --gateway=10.100.0.1 -o parent=bond0.479 PXE_core

Komenda uruchomienia kontenera w tym wypadku to:

docker run -dt --network PXE_core -v /srv/tftp/templates:/srv/templates -v /srv/tftp/templates/CONFIGS/boipxePXECORE/etc:/srv/etc --name boipxe boipxe

gdzie:
   -v /srv/tftp/templates:/srv/templetes - to mapowanie katalogu z obrazami (montowany z MFS-a) na katalog serwowany przez http w celu zdalnego bootowania

   -v -v /srv/tftp/templates/CONFIGS/boipxePXECORE/etc:/srv/etc - to mapowanie katalogu z konfiguracją kontenera
