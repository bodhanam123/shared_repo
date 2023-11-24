-- start materialization macro

    {% materialization external_table, adapter='bigquery' %}

    -- start setting variables

        {%- set target_relation = this %}
        {% set upload_as=config.get('upload_as') %}

        {% set options %}

        OPTIONS(
        format = "GOOGLE_SHEETS",
        sheet_range = "{{config.get('sheet_range')}}",
        uris =  ["{{config.get('uri')}}"],
        skip_leading_rows= {{config.get('skip_leading_rows')}}
        );
    
        {% endset %}

        {%- set temp_table %}
            `{{ this.database }}`.`{{this.schema}}`.`{{this.schema}}_temp_table`
        {% endset %}

    -- end setting varibales

    -- ifelse block to call a macro based on upload_as argument

        {% if upload_as == "external_table" %}
            {%- set build_sql = create_external_table(target_relation,options,model) -%}
        {% elif upload_as == "table" %}
            {%- set build_sql = create_table(target_relation,options,temp_table,model) -%}
        {% else %}
            {%- set build_sql = "" -%}
        {% endif %}

    -- end ifelse block

    -- start running build_sql 
        
        {{- run_hooks(pre_hooks) -}}

        {%- call statement('main') -%}
            {{ build_sql }}
        {% endcall %}
            
        {{ run_hooks(post_hooks) }}
        
        {% set target_relation = this.incorporate(type='table') %}
        {% do persist_docs(target_relation, model) %}
        {{ return({'relations': [target_relation]}) }}
    --end running build_sql

    {% endmaterialization %}

-- end materialization macro



-- macro for external table creation

    {% macro create_external_table(target_relation,options,model) %}

        create or replace external table {{target_relation}}
        {{model.compiled_sql}}
        {{options}}

    {% endmacro %}


-- macro for creating external table as table

    {% macro create_table(target_relation,options,temp_table,model) %}

      create or replace external table {{temp_table}}
      {{model.compiled_sql}}
      {{options}}
      create or replace table {{target_relation}} as (select * from {{temp_table}});
      drop table {{temp_table }} ;
    
      
    
    {% endmacro %}



