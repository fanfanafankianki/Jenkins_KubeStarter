pipelineJob('Terraform_Infrastracture_create_pipeline') {
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://github.com/fanfanafankianki/Jenkins_KubeStarter.git')
                    }
                    branch('main')
                }
            }
            scriptPath('Terraform_stack_pipelines/DSL_A_terraform_stack_create.groovy')
        }
    }
}
