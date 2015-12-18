# Version 11.1.2.2

## Download Software

Download the software packages from
[edelivery.oracle.com](https://edelivery.oracle.com/), see at the end
of this file for a complete list with checksums.


## Create Installation Image Directory

You will need the following software packages from Oracle:

Extract the installation images in a directory on your local machine (when
deploying to VM on your local machine) or on a network server. This
directory will be mounted on the new servers via NFS. There is no need
to copy the files onto the new virtual machines, the installer can read
them from any mounted location.

The structure with the extracted images shall look like this:

```
    ├── iam-11.1.2.2                <- the application packages
    │   ├── repo
    │   │   └── installers
    │   │       ├── appdev
    │   │       ├── fmw_rcu
    │   │       ├── iamsuite
    │   │       ├── idmlcm
    │   │       ├── jdk
    │   │       ├── oud
    │   │       ├── smart_update
    │   │       ├── soa
    │   │       ├── webgate
    │   │       ├── weblogic
    │   │       └── webtier
    ├── database-ee-11.2.0.4        <- the databaes packages
    │   └── p13390677_112040_Linux-x86-64
    │       ├── client
    │       ├── database
    │       ├── deinstall
    │       ├── examples
    │       ├── gateways
    │       └── grid
    ├── patches                     <- common location for software patches
    │   │   ├── ...
```

## Patch the installation images

The installation images need patching to be installed properly.
Download from [Oracle Support](https://support.oracl.com) the following
patch and apply it to the downloaded repository:

```
# fix for wrong 32bit specs: i386 -> i686
patch 18231786
```

You can apply this patch to all products: exchange the old `refhost.xml`
with the new version:

```
./appdev/Disk1/stage/prereq/linux64/refhost.xml
./iamsuite/Disk1/stage/prereq/linux64/refhost.xml
./idmlcm/Disk1/stage/prereq/linux64/refhost.xml
./oud/Disk1/stage/prereq/linux64/refhost.xml
./soa/Disk1/stage/prereq/linux64/refhost.xml
./webgate/Disk1/stage/prereq/linux64/refhost.xml
./webtier/Disk1/stage/prereq/linux64/refhost.xml
```



## Software Packages to Download 

You can verify the checksums online at:

```
https://edelivery.oracle.com/EPD/ViewDigest/get_form?epack_part_number=B77727&export_to_csv=1
```

```
Enterprise Database 11.2.0.4 p13390677
--------------------------------------

Download from Oracle eDelivery:
  https://support.oracle.com

0b399a6593804c04b4bd65f61e73575341a49f8a273acaba0dcda2dfec4979e0  p13390677_112040_Linux-x86-64_1of7.zip
73e04957ee0bf6f3b3e6cfcf659bdf647800fe52a377fb8521ba7e3105ccc8dd  p13390677_112040_Linux-x86-64_2of7.zip
09c08ad3e1ee03db1707f01c6221c7e3e75ec295316d0046cc5d82a65c7b928c  p13390677_112040_Linux-x86-64_3of7.zip
88b4a4abb57f7e94941fe21fa99f8481868badf2e1e0749522bba53450f880c2  p13390677_112040_Linux-x86-64_4of7.zip
f9c9d077549efa10689804b3b07e3efd56c655a4aba51ec307114b46b8eafc5f  p13390677_112040_Linux-x86-64_5of7.zip
b2e08f605d7a4f8ece2a15636a65c922933c7ef29f7ad8b8f71b23fe1ecbaca8  p13390677_112040_Linux-x86-64_6of7.zip
1cb47b7c0b437d7d25d497ed49719167a9fb8f97a434e93e4663cfa07590e2ba  p13390677_112040_Linux-x86-64_7of7.zip


Identity and Access Management
------------------------------

Download from Oracle eDelivery:
  https://edelivery.oracle.com/EPD/Download/get_form?egroup_aru_number=15364661

Oracle Identity and Access Management Deployment Repository 11.1.2.2.0, Linux x86-64, part 1 of 2 (Part 1 of 4)
  SHA-1         4326D264BA21CC87AE724CF6B5D3B130A966579B
Oracle Identity and Access Management Deployment Repository 11.1.2.2.0, Linux x86-64, part 1 of 2 (Part 2 of 4)
  SHA-1         C1AC8EEA2ADD699EE6D8723445D5FCBE8603DAFF
Oracle Identity and Access Management Deployment Repository 11.1.2.2.0, Linux x86-64, part 1 of 2 (Part 3 of 4)
  SHA-1         7FB76DF9ACE7B0E54F4B8448307720DBA8635071
Oracle Identity and Access Management Deployment Repository 11.1.2.2.0, Linux x86-64, part 1 of 2 (Part 4 of 4)
  SHA-1         B9739C4D0B3A9D704FB7356F946E049882616637
Oracle Identity and Access Management Deployment Repository 11.1.2.2.0, Linux x86-64, part 2 of 2 (Part 1 of 3)
  SHA-1         F96849F2781B581419A1852865C44C6E69881B21
Oracle Identity and Access Management Deployment Repository 11.1.2.2.0, Linux x86-64, part 2 of 2 (Part 2 of 3)
  SHA-1         560C49239B05C4DC7DEF69B44865FF19894F0846
Oracle Identity and Access Management Deployment Repository 11.1.2.2.0, Linux x86-64, part 2 of 2 (Part 3 of 3)
  SHA-1         71E1FE0A15FC54DBC7EAC279F7B6FB8E4B879CC3

p18231786_111220_Generic.zip - Patch for installation images
  SHA-1         72d6dc6c1e970e44736ba25f50723645ebc9bd10
```

