============
Mastodon Bot
============

This directory contains source files and documentation for a Mastodon bot running on AWS Lamdba. The bot can be built with the ``Dockerfile`` in the project root and then deployed onto AWS. The bot templates prompts and uses Google's ``generativeai`` library to generate "*toots*" that are posted to the Mastodon API via the ``Mastodon.py`` library. Specifications are given in more detail below. 

Quickstart
==========

These are common commands that are useful in the context of the project. Ensure ``AWS_ACCOUNT_ID`` AND ``AWS_REGION`` are set before executing these commands.

Build
-----

**ECR Login**

.. code-block:: bash

    gmoore@mendicant-bias mastodon % aws ecr get-login-password --region $AWS_REGION |\
        docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

**Image Build**

.. code-block:: bash

    gmoore@mendicant-bias mastodon % docker buildx build \
        --platform linux/amd64 \
        -t $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/mastodon-bot:1.60 \
        --load .

**Image Push**

.. code-block:: bash

    gmoore@mendicant-bias mastodon % docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/mastodon-bot:1.60

Debug
-----

**Retrieve Secrets**

.. code-block:: bash 


    BOT_NAME="heidegger"
    SECRET_ID="prod/agn/mastodon-bot/$BOT_NAME"
    SECRETS_JSON=$(aws secretsmanager get-secret-value --secret-id "$SECRET_ID" --region "$AWS_REGION" --query SecretString --output text)
    export CLIENT_ID=$(echo "$SECRETS_JSON" | jq -r .client_id)
    export CLIENT_SECRET=$(echo "$SECRETS_JSON" | jq -r .client_secret)
    export ACCESS_TOKEN=$(echo "$SECRETS_JSON" | jq -r .access_token)
    export API_BASE_URL=$(echo "$SECRETS_JSON" | jq -r .api_base_url)

**Get Context**

.. code-block:: python 

    from mastodon import Mastodon

    mast = Mastodon(client_id=os.getenv('CLIENT_ID'), client_secret=os.getenv('CLIENT_SECRET'), access_token=os.getenv('ACCESS_TOKEN'),api_base_url=os.getenv('API_BASE_URL'))

    # get latest toots
    toots = [ mastodon.account_statuses(mastodon.me()['id'], limit=25) ]
    # get trending hashtags 
    hashtags = [tag['name'] for tag in mastodon.trending_tags(limit=10)]
    # get local timeline 
    local_timeline = mastodon.timeline_local(limit=10)
    # get public timeline 
    public_timeline = mastodon.timeline_public(limit=10)

**Get State**

.. code-block:: python

    import boto3 

    state = boto3.resource('dynamodb').Table('mastodon-bot')
    current_state = state.get_item(Key = { 'persona': '<persona>' }).get('Item', {})
    # get last processed mention
    #   see NOTE #1 in lambda_function.py for more detail.
    last_processed_mention_id = current_state.get('last_processed_mention_id')
    hacked_notifications = mastodon.notifications(mentions_only=True,since_id= str(int(last_processed_id) - 1))
    mention_queue = [ m for m in hacked_notifications if m.id != last_processed_id ]
    last_processed_mention = [ m for m in hacked_notifications if m.id == last_processed_id ][0]
    # get memory
    memory = current_state.get('memory')

**Render Template**

.. code-block:: bash

    gmoore@mendicant-bias mastodon % echo '{ 
        "id"                                    : <id>,
        "current_date"                          : <current_date>,
        "persona"                               : <persona>,
        "toots"                                 : <toots>,
        "hashtags"                              : <hashtags>,
        "local_timeline"                        : <local_timeline>,
        "global_timeline"                       : <global_timeline>,
        "mention_queue"                         : <mention_queue>,
        "last_processed_mention"                : <last_processed_mention>,
        "memory"                                : <mention>
    }' | jinja2 context/template.rst > rendered.rst

Documentation
-------------

- `Mastodon.py <https://mastodonpy.readthedocs.io/en/stable/>`
- `Google GenAI <https://googleapis.github.io/python-genai/>`_
- `Google Gemini <https://ai.google.dev/gemini-api/docs>`_
- `Jinja2 <https://jinja.palletsprojects.com/en/stable/>`_

Environment
-----------

**State**

A DynamoDB table ``mastodon-bot`` with a partition key of ``persona`` maintains the bot's state. The state has the following properties.

- ``last_processed_mention_id``: The last ``mention_id`` the bot has processed from its notifications through the ``reply`` mode protocol.
- ``memory``: A block of text the LLM can use to persist data across executions.

.. note::

    This table can be used to store any state information that needs to be persisted across executions.

**Secrets**

Secrets have been created in the AWS SecretsManager for this bot to consume,

- ``prod/mastodon-bot/<persona>``: Keyed values for the Mastodon API, where ``<persona>`` is the bot's persona.
- ``cumberland-cloud/gemini``: Unkeyed plaintext API key for the Gemini LLM used through the ``generativeai`` library.

Source Code
===========

The source code is maintained in a Github repository `github.com/chinchalinchin/mastodon-bot.git`_ along with the static content of the website. 

Project Structure 
-----------------

.. code-block:: bash
    
    gmoore@mendicant-bias mastodon % tree
    .
    ├── context
    │   ├── dashboards
    │   │   └── mastodon.rst
    │   ├── pages
    │   │   ├── about.rst
    │   │   ├── contest.rst
    │   │   └── submissions.rst
    │   ├── personas
    │   │   ├── cioran.rst
    │   │   ├── crowley.rst
    │   │   ├── cummings.rst
    │   │   ├── frege.rst
    │   │   ├── heidegger.rst
    │   │   ├── keats.rst
    │   │   ├── sartre.rst
    │   │   ├── tarski.rst
    │   │   └── wittgenstein.rst
    │   └── template.rst
    ├── Dockerfile
    ├── lambda_function.py
    ├── README.rst
    └── requirements.txt

    5 directories, 18 files

.. _specification:

Specification
=============

.. _input:

Input
-----

The Lambda function must be called with input structured as follows,


.. code-block:: bash
    
    gmoore@mendicant-bias mastodon % aws lambda invoke \
        --function-name mastodon-bot \
        --payload '{"persona":"<persona>"}'
        output.txt

Where persona must be one of values in ``context/personas/*``. Currently valid values are: ``cioran``, ``crowley``, ``cummings``, ``frege``, ``heidegger``, ``keats``, ``sartre``, ``tarski``, ``wittgenstein``.

.. _response-schema:

Response Schema
---------------

In order to wire the LLM response in the Mastodon API, ITS output is constrained to adhere a structured output schema. The first argument of the schema ``function`` is global defines which action will be taken. The rest of the schema depends on which action has been selected.

.. topic:: Required Argument

    - **function** | string: The function to execute. Must be one of the values, ``status_post``, ``status_reblog``, ``status_favourite``

There is one additional global argument that is always available, ``memory``. 

.. topic:: Optional Argument

    - **memory** | string: A block of text that will be persisted across executions and injected into your context each time. See :ref:`memory` for its current value. **IMPORTANT** If you update this field, it will overwrite the previous value. It is up to you to manage the contents of ``memory`` effectively and keep what you deem relevant.

The following sections go into more detail for each functional schema. 

.. _status-post:

-----------
status_post
-----------

.. code-block:: json 

    {
        "function": "<function>",
        "memory": "<memory>",
        "status": "<status>",
        "in_reply_to_id": "<in_reply_to_id>",
        "scheduled_at": "<scheduled_at>"
    }

Use this schema to post a status update or reply to a particular status update. 

- **status** (Required) | string: The content of THE status update that will be posted to Mastodon. 
- **in_reply_to_id** (Optional) | string: The ID of the status to which to reply. 
- **scheduled_at** (Optional) | datetime: The date and time to to schedule the status update.

.. _status-reblog:

-------------
status_reblog
-------------

.. code-block:: json 

    {
        "function": "<function>",
        "id": "<id>"
    }

Use this schema to reblog a status update. 

- **id** (Required) | string: The ID of the status to reblog.

.. _status-favourite:

----------------
status_favourite
----------------

.. code-block:: json 

    {
        "function": "<function>",
        "id": "<id>"
    }

Use this schema to add a status update to favourites.

- **id** (Required) | string: The ID of the status to favourite.

.. _template:

Template
--------

- ``context/template.rst``: This is the main template. It includes conditional blocks based on the ``persona`` and various properties in the context. 
- ``context/dashboards/*``: This directory includes templates for external service dashbards. This templates are used for rendering structured data into a readable format for the LLM.
- ``context/pages/*``: This directory includes static content from the main webpages.
- ``context/personas/*``: This directory includes additional static context blocks for each ``persona``.

TODO
====

None