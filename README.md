websphere
============

**WARNING:** This is work in progress, it does not work and will destroy your infrastructure, set your admins on fire and play Iron Maiden very loud. Check back soon for updates. We expect to launch a monkey in space by the end of this year, your donations are welcome.

Chef Cookbook to install and configure several WebSphere applications:, this includes:

 * IBM HTTP Server (ihs)
 * IBM Installation Manager (iim)
 * WebSphere SDK Java (sdk)
 * WebSphere Supplements (suppl)
 * WebSphere Application Server Network Deployment (wasnd)

Additional critics can be obtained by adding a subtree as a remote, referred to in the shorter form as such:

From the hackers at l00kout!

```
   git subtree add --prefix test/support/foodcritic/lookout http://github.com lookout/lookout-foodcritic-rules master --squash
   git remote add -f test/support/foodcritic/lookout http://github.com/lookout/lookout-foodcritic-rules
```

From the dealers in the Bronx:

```
   git subtree add --prefix test/support/foodcritic/etsy http://github.com/etsy/foodcritic-rules.git master --squash
   git remote add -f test/support/foodcritic/etsy http://github.com/etsy/foodcritic-rules.git
```

From the company that wants to be a tattoo shop:

```
   git subtree add --prefix test/support/foodcritic/customink http://github.com/customink-webops/foodcritic-rules.git master --squash
   git remote add -f test/support/foodcritic/customink http://github.com/customink-webops/foodcritic-rules.git
```

