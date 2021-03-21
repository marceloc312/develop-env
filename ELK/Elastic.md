#Configuração ELK

* Ambiente Docker


## Manager ELK

* Criando Policy usando o Console do Kibana (DevTool)

PUT _ilm/policy/delete-logs-after-30d
body: policy.json

* Criando o template de logs

PUT _index_template/log-tegma-cisa-carimba-pdf
body: template.json

* Aplicar as configurações a indices já existentes

/*APLICA A POLICY DE EXCLUSÃO PARA OS INDICES DESEJADOS*/
PUT freightverifygm-service-2021*/_settings 
body: aplicar-a-index-existentes.json
```js
{
    "index": {
        "lifecycle": {
            "name": "delete-logs-after-30d",
            "indexing_complete": true,
            "rollover_alias": "freightverifygm2020"
        }
    }
} 
```

## Politicas de Logs
* Information - 1 semana
* Warning - 2 semanas
* Error - 1 mês