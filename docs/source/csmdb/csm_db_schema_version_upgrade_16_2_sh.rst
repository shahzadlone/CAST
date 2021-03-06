Using csm_db_schema_version_upgrade_16_2.sh
===========================================

.. important:: Prior steps before migrating to the newest DB schema version.

#. Stop all CSM daemons
#. Run a cold backup of the csmdb or specified DB (:ref:`csm_db_backup_script_v1.sh <csm_db_backup_script_v1.sh>`)
#. Install the newest RPMs
#. Run the :ref:`csm_db_schema_version_upgrade_16_2.sh <usage>`
#. Start CSM daemons

.. attention:: To migrate the CSM database from ``15.0, 15.1, 16.0, or 16.1`` to the newest schema version

.. code-block:: bash

 /opt/ibm/csm/db/csm_db_schema_version_upgrade_16_2.sh <my_db_name>
 
.. note:: The ``csm_db_schema_version_upgrade_16_2.sh`` script creates a log file: ``/var/log/ibm/csm/csm_db_schema_upgrade_script.log``

| This script upgrades the CSM (or other specified) DB to the newest schema version (``16.2``).

| The script has the ability to alter tables, field types, indexes, triggers, functions, and any other relevant DB updates or requests. The script will only modify or add specificfields to the database and never eliminating certain fields.
  
.. note:: For a quick overview of the script functionality:

.. code-block:: bash

 /opt/ibm/csm/db/ csm_db_schema_version.sh –h
 /opt/ibm/csm/db/ csm_db_schema_version.sh --help
 If the script is ran without any options, then the usage function is displayed.

.. _usage:

Usage Overview
--------------
.. code-block:: bash

 -bash-4.2$ ./csm_db_schema_version_upgrade_16_2.sh -h
 -------------------------------------------------------------------------------------------------
 [Start   ] Welcome to CSM database schema version upgrade schema script.
 [Error   ] Please specify DB name
 =================================================================================================
 [Info    ] csm_db_schema_version_upgrade.sh : Load CSM DB upgrade schema file
 [Usage   ] csm_db_schema_version_upgrade.sh : csm_db_schema_version_upgrade.sh [DBNAME]
 -------------------------------------------------------------------------------------------------
   Argument       |  DB Name  | Description
 -----------------|-----------|-------------------------------------------------------------------
   script_name    | [db_name] | Imports sql upgrades to csm db table(s) (appends)
                  |           | fields, indexes, functions, triggers, etc
 -----------------|-----------|-------------------------------------------------------------------
 =================================================================================================

Upgrading CSM DB (manual process)
---------------------------------

.. note:: To upgrade the CSM or specified DB:

.. code-block:: bash
 
 /opt/ibm/csm/db/csm_db_schema_version_upgrade_16_2.sh <my_db_name> (where my_db_name is the name of your DB).
 
.. note:: The script will check to see if the given DB name exists. If the database name does not exist, then it will exit with an error message.

Example (non DB existence):
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

 -bash-4.2$ ./csm_db_schema_version_upgrade_16_2.sh csmdb
 -------------------------------------------------------------------------------------
 [Start   ] Welcome to CSM database schema version upgrate script.
 [Info    ] PostgreSQL is installed
 [Error   ] Cannot perform action because the csmdb database does not exist. Exiting.
 -------------------------------------------------------------------------------------

.. note::
  The script will check for the existence of these files:
   * ``csm_db_schema_version_data.csv``
   * ``csm_create_tables.sql``
   * ``csm_create_triggers.sql``
 
When an upgrade process happens, the new RPM will consist of a new schema version csv, DB create tables file, and or create triggers/functions file to be loaded into a (completley new) DB.
 
| Once these files have been updated then the migration script can be executed.  There is a built in check that does a comparison againt the DB schema version and the associated files. (These are just a couple of the check processes that takes place)

Example (non csv_file_name existence):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

 -bash-4.2$ ./csm_db_schema_version_upgrade_16_2.sh csmdb
 -------------------------------------------------------------------------------------
 [Start   ] Welcome to CSM database schema version upgrate script.
 [Error   ] File csm_db_schema_version_data.csv can not be located or doesnt exist
 -------------------------------------------------------------------------------------

.. note:: The second check makes sure the file exists and compares the actual SQL upgrade version to the hardcoded version number. If the criteria is met successfully, then the script will proceed.  If the process fails, then an error message will prompt.

Example (non compatible migration):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

 -bash-4.2$ ./csm_db_schema_version_upgrade_16_2.sh csmdb
 -------------------------------------------------------------------------------------
 [Start   ] Welcome to CSM database schema version upgrate script.
 [Error   ] Cannot perform action because not compatible.
 [Info    ] Required DB schema version 15.0, 15.1, 16.0, 16.1 or appropriate files in directory
 [Info    ] csmdb current_schema_version is running: 16.1
 [Info    ] csm_create_tables.sql file currently in the directory is: 15.1 (required version) 16.2
 [Info    ] csm_create_triggers.sql file currently in the directory is: 16.2 (required version) 16.2
 [Info    ] csm_db_schema_version_data.csv file currently in the directory is: 16.2 (required version) 16.2
 [Info    ] Please make sure you have the latest RPMs installed and latest DB files.
 -------------------------------------------------------------------------------------

.. note:: If the user selects the ``"n/no"`` option when prompted to migrate to the newest DB schema upgrade, then the program will exit with the message below.

Example (user prompt execution with “n/no” option):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

 -bash-4.2$ ./csm_db_schema_version_upgrade_16_2.sh csmdb
 -------------------------------------------------------------------------------------
 [Start   ] Welcome to CSM database schema version upgrate script.
 [Info    ] PostgreSQL is installed
 [Info    ] csmdb current_schema_version 16.1
 [Info    ] csmdb schema_version_upgrade: 16.2
 [Warning ] This will migrate csmdb database to schema version 16.1. Do you want to continue [y/n]?:
 [Info    ] User response: n
 [Error   ] Migration session for DB: csmdb User response: ****(NO)****  not updated
 ---------------------------------------------------------------------------------------------------------------

.. note:: If the user selects the ``"y/yes"`` option when prompted to migrate to the newest DB schema upgrade, then the program will begin execution. An additional section has been added to the migration script to update existing ras message types or to insert new cases.  The user will have to specify ``y/yes`` for these changes or ``n/no`` to skip the process. If there are no changes to the RAS message types or no new cases then the information will be displayed accordingly.

Example (user prompt execution with “y/yes” options for both):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

 -bash-4.2$ ./csm_db_schema_version_upgrade_16_2.sh csmdb
 ------------------------------------------------------------------------------------------------------------------------
 [Start   ] Welcome to CSM database schema version upgrade script.
 [Info    ] PostgreSQL is installed
 [Info    ] csmdb current_schema_version 16.1
 [Info    ] csmdb schema_version_upgrade: 16.2
 [Warning ] This will migrate csmdb database to schema version 16.2. Do you want to continue [y/n]?:
 [Info    ] User response: y
 [Info    ] csmdb migration process begin.
 [Info    ] There are no connections to csmdb
 -------------------------------------------------------------------------------------
 [Start   ] Welcome to CSM database ras type automation script.
 [Info    ] csm_ras_type_data.csv file exists
 [Info    ] PostgreSQL is installed
 [Warning ] This will load and or update csm_ras_type table data into csmdb database. Do you want to continue [y/n]?
 [Info    ] User response: y
 [Info    ] csm_ras_type record count before script execution: 520
 [Info    ] Record import count from csm_ras_type_data.csv: 737
 [Info    ] Record update count from csm_ras_type_data.csv: 5
 [Info    ] Total csm_ras_type insert count from file: 217
 [Info    ] csm_ras_type live row count after script execution: 737
 [Info    ] csm_ras_type_audit live row count: 742
 [Info    ] Database: csmdb csv upload process complete for csm_ras_type table.
 ------------------------------------------------------------------------------------
 [Complete] csmdb database schema update 16.2.
 ------------------------------------------------------------------------------------------------------------------------
 [Timing  ] 0:00:00:1.8838
 ------------------------------------------------------------------------------------------------------------------------

Example (user prompt execution with “y/yes” for the migration and “n/no” for the RAS section):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

 -bash-4.2$ ./csm_db_schema_version_upgrade_16_2.sh csmdb
 ------------------------------------------------------------------------------------------------------------------------
 [Start   ] Welcome to CSM database schema version upgrade script.
 [Info    ] PostgreSQL is installed
 [Info    ] csmdb current_schema_version 16.1
 [Info    ] csmdb schema_version_upgrade: 16.2
 [Warning ] This will migrate csmdb database to schema version 16.2. Do you want to continue [y/n]?:
 [Info    ] User response: y
 [Info    ] csmdb migration process begin.
 [Info    ] There are no connections to csmdb
 -------------------------------------------------------------------------------------
 [Start   ] Welcome to CSM database ras type automation script.
 [Info    ] csm_ras_type_data.csv file exists
 [Info    ] PostgreSQL is installed
 [Warning ] This will load and or update csm_ras_type table data into csmdb database. Do you want to continue [y/n]?
 [Info    ] User response: n
 [Info    ] Skipping the csm_ras_type table data import/update process
 ------------------------------------------------------------------------------------
 [Complete] csmdb database schema update 16.2.
 ------------------------------------------------------------------------------------------------------------------------
 [Timing  ] 0:00:00:1.0024
 ------------------------------------------------------------------------------------------------------------------------

.. attention:: It is not recommended to select ``n/no`` for the RAS section during the migration script process.  If this process does occur, then the RAS script can be ran alone by the system admin.


To run the RAS script by itself please refer to link: :ref:`csm_ras_type_script_sh <csm_ras_type_script_usage>`

.. note:: If the migration script has already ran already or a new database has been created with the latest schema version of ``16.2`` then this message will be prompted to the user.
 
Running the script with existing newer version
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: bash
 
 -bash-4.2$ ./csm_db_schema_version_upgrade_16_2.sh csmdb
 -------------------------------------------------------------------------------------------------
 [Start   ] Welcome to CSM database schema version upgrade script.
 [Info    ] PostgreSQL is installed
 [Info    ] csmdb is currently running db schema version: 16.2
 -------------------------------------------------------------------------------------------------

.. warning:: If there are existing DB connections, then the migration script will prompt a message and the admin will have to kill connections before proceeding.

.. hint:: The csm_db_connections_script.sh script can be used with the –l option to quickly list the current connections. (Please see user guide or ``–h`` for usage function).  This script has the ability to terminate user sessions based on pids, users, or a ``–f`` force option will kill all connections if necessary.  Once the connections are terminated then the ``csm_db_schema_version_upgrade_16_2.sh`` script can be executed. The log message will display current connection of user, database name, connection count, and duration.

Example (user prompt execution with “y/yes” option and existing DB connection(s)):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

 -bash-4.2$ ./csm_db_schema_version_upgrade_16_2.sh csmdb
 ---------------------------------------------------------------------------------------------------
 [Start   ] Welcome to CSM database schema version upgrate script.
 [Info    ] PostgreSQL is installed
 [Info    ] csmdb current_schema_version 16.1
 [Info    ] csmdb schema_version_upgrade: 16.2
 [Warning ] This will migrate csmdb database to schema version 16.1. Do you want to continue [y/n]?:
 [Info    ] User response: y
 [Info    ] csmdb migration process begin.
 [Error   ] csmdb has existing connection(s) to the database.
 [Error   ] User: csmdb has 1 connection(s)
 [Info    ] See log file for connection details
 ---------------------------------------------------------------------------------------------------
