
# Construa uma Aplicação Nativa Spring

```mvn -Pnative native:compile```

É um comando padrão de compilação nativa que funcionaria em qualquer aplicação Spring Boot com suporte a GraalVM Native Image habilitado como uma dependência.

# Motor AOT do Spring Boot e GraalVM

# Modo Dev

Para fins de desenvolvimento, você pode acelerar as compilações nativas passando a flag `-Ob`: seja via linha de comando, ou no plugin Maven Nativo:

```xml
<plugin>
  <groupId>org.graalvm.buildtools</groupId>
      <artifactId>native-maven-plugin</artifactId>
          <configuration>
              <buildArgs>
                  <buildArg>-Ob</buildArg>
              </buildArgs>
            </configuration>
</plugin>
```

Isso acelerará a fase de compilação, e portanto o tempo total de construção será ~15-20% mais rápido.

Isso é destinado como um modo dev, certifique-se de remover a flag antes de implantar em produção para obter o melhor desempenho.

# Otimizar desempenho

## PGO 🚀

Uma das otimizações de desempenho mais poderosas em Native Image é otimizações guiadas por perfil (PGO).


1. Construa uma imagem instrumentada: 

```mvn -Pinstrumented native:compile```

2. Execute o aplicativo e aplique a carga de trabalho relevante:

```./target/demo-instrumented```

```hey -n=1000000 http://localhost:8080/hello```

depois de desligar o aplicativo, você verá um arquivo iprof em seu diretório de trabalho.

3. Construa um aplicativo com perfis (eles são selecionados via `<buildArg>--pgo=${project.basedir}/default.iprof</buildArg>`):

```mvn -Poptimized native:compile```


## PGO habilitado para ML 👩‍🔬

A abordagem PGO descrita acima, onde os perfis são coletados e adaptados para o seu aplicativo, é a maneira recomendada de fazer PGO em Native Image.

No entanto, pode haver situações em que a coleta de perfis não é possível - por exemplo, por causa do seu modelo de implantação ou outros motivos. Nesse caso, ainda é possível obter informações de perfil e otimizar o aplicativo com base nelas via PGO habilitado para ML. Native Image contém um modelo ML pré-treinado que prevê as probabilidades dos ramos do gráfico de fluxo de controle, o que nos permite otimizar adicionalmente o aplicativo. Isso está novamente disponível no Oracle GraalVM e você não precisa ativá-lo - ele é acionado automaticamente na ausência de perfis personalizados.

Se você está curioso sobre o impacto dessa otimização, pode desativá-la com `-H:-MLProfileInference`. . Em nossas medições, essa otimização fornece ~6% de melhoria no desempenho em tempo de execução, o que é muito legal para uma otimização que você obtém automaticamente.


## G1 GC 🧹

Pode haver diferentes estratégias de GC. O GC padrão em Native Image, Serial GC, pode ser benéfico em certos cenários, por exemplo, se você tem um aplicativo de curta duração ou quer otimizar o uso de memória.

Se você está visando o melhor pico de rendimento, nossa recomendação geral é tentar o G1 GC (Note que você precisa do Oracle GraalVM para isso).

Em nosso perfil  `optimized`  ele é ativado via `<buildArg>--gc=G1</buildArg>`.

## Nivel de otimização para Imagens Nativas 📈

Existem vários níveis de otimizações em Native Image, que podem ser definidos no momento da construção:

- `-O0` - Sem otimizações: Nível de otimização recomendado para depuração de imagens nativas;

- `-O1` -  Otimizações básicas: Otimizações básicas do compilador GraalVM, ainda funciona para depuração;
 
- `-O2`  - Otimizações avançadas: nível de otimização padrão para Native Image;

- `-O3` - Todas as otimizações para melhor desempenho;

- `-Ob` - -Ob - Otimizar para o tempo de construção mais rápido: use apenas para fins de desenvolvimento para um feedback mais rápido, remova antes de compilar para implantação;

- `-pgo`: Usar PGO acionará automaticamente `-O3` para melhor desempenho.
  
# Testing 🧪

As Ferramentas de Construção Nativa do GraalVM suportam o teste de aplicativos como imagens nativas, incluindo suporte ao JUnit. A maneira como isso funciona é que seus testes são compilados como executáveis nativos para verificar se as coisas funcionam no mundo nativo como esperado. Teste nosso aplicativo com o seguinte:

 ```mvn -PnativeTest test```

`HttpRequestTest` verificará se nosso aplicativo retorna a mensagem esperada.

Recomendação de teste nativo: você não precisa testar no modo o tempo todo, especialmente se estiver trabalhando com frameworks e bibliotecas que suportam Native Image - geralmente tudo funciona. Desenvolva e teste seu aplicativo na JVM, e teste em Native de vez em quando, como parte de seu processo de CI/CD, ou se você estiver introduzindo uma nova dependência, ou mudando coisas que são sensíveis para Native Image (reflexão etc). 

# Using libraries

# Configuring reflection

# Monitoring 📈




