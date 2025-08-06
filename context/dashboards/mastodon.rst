.. _feed:

Feed
----

{% if local_timeline | length > 0 %}
------------------
Latest Local Toots
------------------

This contains the latest toots posted to the server.

{% for toot in local_timeline %}
**(ID: {{ toot.id }}) {{ toot.account.display_name }}, @{{ toot.account.username }}** 

{{ toot.content | striptags }}
{% if toot.context and toot.context.ancestors %}
.. topic:: In reply to

    {% for ancestor in toot.context.ancestors %}
    - (ID: {{ ancestor.id }}) {{ ancestor.account.display_name }}, @{{ ancestor.account.username }}: {{ ancestor.content | striptags }}
    {% endfor %}
{% endif %}
{% endfor %}
{% endif %}

{% if global_timeline | length > 0 %}
--------------------
Latest Global Toots
--------------------

This is a list of the latest toots posted to the federated servers.

{% for toot in global_timeline %}
- (ID: {{ toot.id }}) {{ toot.account.display_name }}, @{{ toot.account.username }}: {{ toot.content | striptags }}
{% endfor %}
{% endif %}

{% if hashtags | length > 0 %}
------------------------
Trending Global Hashtags
------------------------

This is a list of the top trending hashtags on the server. You are not required to use a hashtag in your response unless it serves the themes of your post.

{% for tag in hashtags %}
- {{ tag }}
{% endfor %}
{% endif %}

Your Profile
------------

This section details your own feed and profile.

------------
Your History
------------

{% if toots | length > 0 %}
This is a list of your most recent toots.

{% for toot in toots %}
**(ID: {{ toot.id }}) {{ toot.account.display_name }}, @{{ toot.account.username }}** 

Date: {{ toot.created_at }}

{{ toot.content | striptags }}

{% if toot.context and toot.context.ancestors %}
.. topic:: In Reply To

    {% for ancestor in toot.context.ancestors %}
    - (ID: {{ ancestor.id }}) {{ ancestor.account.display_name }}, @{{ ancestor.account.username }}: {{ ancestor.content | striptags }}
    {% endfor %}
{% endif %}
{% endfor %}
{% else %}
You have not tooted yet.
{% endif %}

---------------
Your Favourites
---------------

{% if favourites | length > 0 %}
This is a list of toots you have favourited.

{% for fav in favourites %}
- (ID: {{ fav.id }}), {{ fav.created_at }}: {{ fav.context }} 
{% endfor %}
{% else %}
You have not favourited anything yet.
{% endif %}

-----------------------
Last Processed Mention
-----------------------

{% if last_processed_mention %}
This is the last mention you replied to.

**(ID: {{ last_processed_mention.status.id }}) {{ last_processed_mention.account.display_name }}, @{{ last_processed_mention.account.username }}**

Date: {{ last_processed_mention.created_at }}

{{ last_processed_mention.status.content | striptags | trim }}
{% else %}
You have not processed any mentions yet.
{% endif %}

-------------
Mention Queue
-------------

{% if mention_queue | length > 0 %}
Here are the mentions waiting for you to reply to, in chronological order.

{% for mention in mention_queue %}
**(ID: {{ mention.status.id }} ) {{ mention.account.display_name }}, @{{ mention.account.username }}**

Date: {{ mention.created_at }}
   
{{ mention.status.content | striptags | trim }}

{% endfor %}
{% else %}
The mention queue is currently empty.
{% endif %}