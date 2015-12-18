Patching
========

In this context patching means applying vendor software patches, so
software patches from Oracle, identified by a distinct patch number.
Usually those patches are OPatches, sometime bsul-patches.

The IAM releases include a set of already included patches, in each
product:

- Suite 11.1.2.2: see document doc/opatch-11.1.2.2.markdown
- Suite 11.1.2.3: see document doc/opatch-11.1.2.3.markdown

## Applying patches during Installation

You can add additional patches already for base installation. There is
no additional configuration needed, just add the extracted patches at 
the following locations in the installation repository:

    Identity Manager:     installer/iamsuite/patch/oim/
    SOA:                  installer/soa/patch/
    WebTier (OHS):        installer/webtier/patch/

Example: the OIM BP6 
