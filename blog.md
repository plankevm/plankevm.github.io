---
layout: default
title: Blog
---

# Blog

<ul class="post-list">
{% for post in site.posts %}
  <li>
    <time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%b %d, %Y" }}</time>
    <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
  </li>
{% endfor %}
</ul>
