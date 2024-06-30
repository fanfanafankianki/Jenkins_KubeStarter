pipelineJob('B_Ansbile_Infrastracture_create_pipeline') {
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
            scriptPath('Terraform_stack_pipelines/B_ansible_stack_create.json')
        }
    }
}
