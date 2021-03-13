# sector_service
Sector -> Industry -> NYSE Symbol
---
# For Ruby on Rails version 6.1.3
# NOTE:
## The output is located in ```sector_map.yml```
---
```ruby
# app/services/sector_service.rb
#
# Copyright 2021
# Matt Feenstra
# All Rights Reserved.
#
# This is a data transformation from a dirty (PostgresDB) source that provides
#   an organized tree, like the the one below:
#
# @data = {  'sector1_name' => [ { 'industry1' => ['aapl', 'msft'] },
#                                { 'industryN' => ['abc', 'dddd']  } ],
#            'sector2_name' => [ { 'industryA' => ['qwe', 'erty']  },
#                                { 'industryB' => ['zzz', 'yyy']   } ]
#         }
```
