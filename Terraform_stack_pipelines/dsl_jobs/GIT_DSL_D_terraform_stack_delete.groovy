pipelineJob('D_Terraform_Infrastracture_delete_pipeline') {
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
            scriptPath('Terraform_stack_pipelines/D_terraform_stack_delete.json')
        }
    }
}
