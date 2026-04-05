<h1 align="center">Send My Book</h1>

<p align="center">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img alt="Dart" src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img alt="Firebase" src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
</p>

## 💻 Sobre o Projeto

**Send My Book** é um aplicativo de gerenciamento de biblioteca pessoal que permite aos usuários organizar, acompanhar e descobrir livros. O sistema integra a API do Open Library para busca de livros e utiliza Firebase como backend para autenticação e armazenamento em nuvem.

### ✨ Principais Funcionalidades

#### Para o Leitor

- 🔐 **Autenticação Segura**: Login, cadastro e recuperação de senha com Firebase Auth
- 📖 **Minha Biblioteca**: Gerencie seus livros com status de leitura (Não lido, Lendo, Lido)
- 📋 **Lista de Desejos**: Salve livros que deseja ler no futuro
- 🔍 **Busca Inteligente**: Pesquise livros pela API do Open Library com preenchimento automático

#### Organização

- 🏷️ **Filtros por Status**: Filtre por Todos, Lendo, Lido, Não lido
- 📊 **Contagem em Tempo Real**: Acompanhe o total de livros na biblioteca
- ✏️ **Edição Completa**: Edite detalhes dos livros a qualquer momento
- 👤 **Perfil do Usuário**: Visualize informações da conta e faça logout

## 📦 Instalação e Configuração

### Pré-requisitos

- **Flutter** SDK 3.0.0+
- **Dart** SDK 3.0.0+
- **Firebase CLI** (para configuração do projeto Firebase)
- **Android Studio** ou **VS Code** com extensões Flutter/Dart

### Passos de Instalação

```bash
# Clone o repositório
git clone git@github.com:seu-usuario/send-my-book.git

# Entre no diretório do projeto
cd send-my-book

# Instale as dependências
flutter pub get
```

### Configuração do Firebase

O projeto utiliza Firebase para autenticação e banco de dados. Configure seu próprio projeto Firebase:

1. Crie um projeto no [Firebase Console](https://console.firebase.google.com/)
2. Ative **Authentication** (Email/Senha) e **Cloud Firestore**
3. Adicione os arquivos de configuração:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`
4. Atualize o arquivo `lib/firebase_options.dart` com suas credenciais

### Executando o Projeto

```bash
# Rode no dispositivo/emulador conectado
flutter run
```

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.
