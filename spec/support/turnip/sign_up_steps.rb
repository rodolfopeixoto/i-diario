# encoding: utf-8
module Turnip
  module SignUpSteps
    step "que acesso a página de signup de pais" do
      visit root_path

      click_link 'Criar conta'

      expect(page).to have_content "Escolha seu perfil"

      click_on "Acesso pais"
    end

    step "informo os dados para o cadastro de pais" do
      VCR.use_cassette('signup_parent') do
        expect(page).to have_content "Informações básicas"

        fill_mask "CPF", with: "729.785.662-21"
        fill_in "Código do aluno", with: "1931"

        sleep 2
      end

      expect(page).to have_content "Alunos"

      within "table" do
        within "tbody tr:nth-child(1)" do
          expect(page).to have_content "ADRIANO ROQUE"
          expect(page).to have_content "544"
        end

        within "tbody tr:nth-child(2)" do
          expect(page).to have_content "ABNER ROCHA"
          expect(page).to have_content "1931"
        end
      end

      expect(page).to have_content "Cadastro do usuário"

      fill_mask "Celular", with: "(31) 94361177"
      fill_in 'E-mail', with: 'clark@example.com'
      fill_in 'Senha', with: '11223344'
      fill_in 'Confirme a senha', with: '11223344'

      click_button 'Confirmar e acessar o sistema'
    end

    step "deverei ser logado ao sistema" do
      expect(page).to have_text 'Bem-vindo! Você se registrou com sucesso.'
    end

    step "que acesso a página de signup de alunos" do
      visit root_path

      click_link 'Criar conta'

      expect(page).to have_content "Escolha seu perfil"

      click_on "Acesso alunos"
    end

    step "informo os dados para o acesso do aluno" do
      expect(page).to have_content "Novo acesso"

      fill_in 'E-mail', with: 'mary@mary.com'
      fill_in 'Senha', with: '11223344'
      fill_in 'Confirme a senha', with: '11223344'

      click_button "Solicitar acesso"
    end

    step "deverei ver a mensagem de acesso solicitado" do
      expect(page).to have_content "Notificamos o responsável da sua unidade escolar sobre sua solicitação. Em breve você receberá um e-mail com o seu acesso."
    end

    step "o login não poderá ser realizado enquanto o acesso estiver pendente" do
      fill_in 'Informe o Nome de usuário, E-mail, Celular ou CPF', with: 'mary@mary.com'
      fill_in 'Senha', with: '11223344'

      click_on 'Acessar'

      expect(page).to have_content 'A sua conta não foi ativada ainda.'
    end

    step "que acesso a página de signup de servidores" do
      visit root_path

      click_link 'Criar conta'

      expect(page).to have_content "Escolha seu perfil"

      click_on "Acesso servidores"
    end

    step "informo os dados para o acesso do servidor" do
      expect(page).to have_content "Novo acesso"

      fill_in 'E-mail', with: 'tony@stark.com'
      fill_in 'Senha', with: '11223344'
      fill_in 'Confirme a senha', with: '11223344'

      click_button "Solicitar acesso"
    end

    step "o servidor não poderá logar enquanto o acesso estiver pendente" do
      fill_in 'Informe o Nome de usuário, E-mail, Celular ou CPF', with: 'tony@stark.com'
      fill_in 'Senha', with: '11223344'

      click_on 'Acessar'

      expect(page).to have_content 'A sua conta não foi ativada ainda.'
    end
  end
end

RSpec.configure do |config|
  config.include Turnip::SignUpSteps
end
