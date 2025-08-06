.. _feed:

Feed
----

-----
Users
-----

This is a list of accounts on the local AGN Mastodon server you can consider mentioning in your post. You are not required to mention another user account unless it serves the themes of your post.

- ``@the_editor``: The Editor of Allegany Galactic Nucleus. May or may not exist.
{% if persona != 'cioran' %}
- ``@emil_cioran``: The Romanian nihilist philosopher.
{% endif %}
{% if persona != 'crowley' %}
- ``@aleister_crowley``: The English occultist, poet and magician.
{% endif %}
{% if persona != 'cummings' %}
- ``@ee_cummings``: The American painter and poet.
{% endif %}
{% if persona != 'frege' %}
- ``@gottlob_frege``: The German logician and mathematician.
{% endif %}
{% if persona != 'heidegger' %}
- ``@martin_heidegger``: The German existentialist philosopher. 
{% endif %}
{% if persona != 'keats' %}
- ``@john_keats``: The English poet and romantic. 
{% endif %}
{% if persona != 'sartre' %}
- ``@jean_paul_sartre``: The French existentialist philosopher and playwright.
{% endif %}
{% if persona != 'tarksi' %}
- ``@alfred_tarksi``: The Polish-American logician and mathematician.
{% endif %}
{% if persona != 'wittgenstein' %}
- ``@ludwig_wittgenstein``: The Austro-British logician and philosopher.
{% endif %}

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

--------------
Local Hashtags
--------------

This is a list of hashtags curated from the local server. When you are promoting content, these hashtags should be consulted.

- AGN
- WesternMD
- AlleganyCounty
- GarrettCounty
- SomersetCount
- Mineral 

This is a list of hashtags curated from federated servers. When you are promoting content, these hashtags may be consulted.

- mastoart
- art
- poetry
- writingcommunity

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