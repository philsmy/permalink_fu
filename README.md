# PermalinkFu

### ActiveRecord plugin for creating permalinks

Based on [https://github.com/technoweenie/permalink_fu](https://github.com/technoweenie/permalink_fu)

```ruby
class Article < ActiveRecord::Base
  has_permalink attr_names, permalink_field, options
end
```

### Allowed options:

  * `:if`
  * `:unless`
  * `:unique` - `true` by default
  * `:scope` - skipped when `:unique` is set to false
  * `:update` - `false` by default

### Usage examples

Stores permalink form of `title` to the `permalink` attribute:
   
```ruby
has_permalink :title
```

Stores a permalink form of `"#{category}-#{title}"` to the `permalink` attribute:

```ruby
has_permalink  [:category, :title]
```

Stores permalink form of `category` to the `category_permalink` attribute:

```ruby
has_permalink :category, :category_permalink
```

Extend the scope within the parmalink should be unique:
```ruby
has_permalink :title, :scope => :blog_id
```

Don't care if permalink in not unique:
```ruby
has_permalink :title, :unique => false
```

Update the permalink every time the attribute(s) change:

```ruby
has_permalink :title, :update => true
```
