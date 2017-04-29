 class { 'kubernetes::client': manage_package => false, }
 class { 'kubernetes::node':   manage_package => false, }
 class { 'kubernetes::master': manage_package => false, }
