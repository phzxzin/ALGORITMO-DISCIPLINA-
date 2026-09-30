algoritmo "UniLibrary"
// ============================================================
// UniLibrary - Sistema de Gerenciamento de Biblioteca Universitaria
// ============================================================

tipo
   // Registro que agrupa todas as informacoes de um livro
   TLivro = registro
      codigo: inteiro
      titulo: caractere
      autor: caractere
      ano: inteiro
      categoria: inteiro
      qtdTotal: inteiro
      qtdDisponivel: inteiro
      qtdEmprestimos: inteiro
      status: inteiro
   fimregistro

var
   // ---------- "Constantes" (VisuAlg nao tem const; valores atribuidos em inicializar) ----------
   MAX_LIVROS, MAX_CATEGORIAS: inteiro
   TECNOLOGIA, EXATAS, HUMANAS, NEGOCIOS, LITERATURA: inteiro
   DISPONIVEL, INDISPONIVEL: inteiro
   EMPRESTIMO, DEVOLUCAO, TIPOS_OPERACAO: inteiro
   ANO_MIN, ANO_MAX, NAO_ENCONTRADO: inteiro

   // ---------- Estruturas globais (VisuAlg nao passa vetor/registro por parametro) ----------
   acervo: vetor[1..40] de TLivro                 // 40 = MAX_LIVROS (sempre ordenado por codigo)
   ranking: vetor[1..40] de TLivro                // copia do acervo, usada so na ordenacao
   movimentacoes: vetor[1..5, 1..2] de inteiro    // [categoria, tipo de operacao]
   livrosPorCat: vetor[1..5] de inteiro           // contador de livros por categoria
   qtdLivros: inteiro                             // posicoes ocupadas no acervo
   opcao: inteiro                                 // opcao do menu

// ============================================================
// INICIALIZACAO
// ============================================================
procedimento inicializar
var i, j: inteiro
inicio
   MAX_LIVROS <- 40
   MAX_CATEGORIAS <- 5
   TECNOLOGIA <- 1
   EXATAS <- 2
   HUMANAS <- 3
   NEGOCIOS <- 4
   LITERATURA <- 5
   DISPONIVEL <- 1
   INDISPONIVEL <- 0
   EMPRESTIMO <- 1
   DEVOLUCAO <- 2
   TIPOS_OPERACAO <- 2
   ANO_MIN <- 1450
   ANO_MAX <- 2026
   NAO_ENCONTRADO <- 0

   qtdLivros <- 0
   // Zera a matriz de movimentacoes (repeticao aninhada)
   para i de 1 ate MAX_CATEGORIAS faca
      livrosPorCat[i] <- 0
      para j de 1 ate TIPOS_OPERACAO faca
         movimentacoes[i, j] <- 0
      fimpara
   fimpara
fimprocedimento

// ============================================================
// FUNCOES AUXILIARES
// ============================================================
funcao nomeCategoria(cat: inteiro): caractere
inicio
   escolha cat
      caso 1
         retorne "Tecnologia"
      caso 2
         retorne "Ciencias Exatas"
      caso 3
         retorne "Ciencias Humanas"
      caso 4
         retorne "Administracao e Negocios"
      caso 5
         retorne "Literatura"
      outrocaso
         retorne "Desconhecida"
   fimescolha
fimfuncao

funcao nomeStatus(st: inteiro): caractere
inicio
   se st = DISPONIVEL entao
      retorne "Disponivel"
   senao
      retorne "Indisponivel"
   fimse
fimfuncao

// qtdEmprestada = qtdTotal - qtdDisponivel
funcao qtdEmprestada(posicao: inteiro): inteiro
inicio
   retorne acervo[posicao].qtdTotal - acervo[posicao].qtdDisponivel
fimfuncao

// Recebe a quantidade de livros cadastrados e diz se o catalogo esta vazio
funcao catalogoVazio(total: inteiro): logico
inicio
   se total = 0 entao
      retorne verdadeiro
   senao
      retorne falso
   fimse
fimfuncao

// Le um inteiro e repete ate estar entre minimo e maximo (permite corrigir)
funcao lerInteiroFaixa(mensagem: caractere; minimo, maximo: inteiro): inteiro
var valor: inteiro
inicio
   repita
      escreva(mensagem)
      leia(valor)
      se (valor < minimo) ou (valor > maximo) entao
         escreval("  Valor invalido! Informe um numero entre ", minimo, " e ", maximo, ".")
      fimse
   ate (valor >= minimo) e (valor <= maximo)
   retorne valor
fimfuncao

// ============================================================
// LOCALIZACAO (linear) - retorna a posicao ou NAO_ENCONTRADO
// ============================================================
funcao localizarLivro(cod: inteiro): inteiro
var i, achou: inteiro
inicio
   achou <- NAO_ENCONTRADO
   i <- 1
   enquanto (i <= qtdLivros) e (achou = NAO_ENCONTRADO) faca
      se acervo[i].codigo = cod entao
         achou <- i
      fimse
      i <- i + 1
   fimenquanto
   retorne achou
fimfuncao

// ============================================================
// COPIA / TROCA DE REGISTROS COMPLETOS (campo a campo)
// ============================================================
procedimento copiarLivro(origem, destino: inteiro)   // acervo -> acervo
inicio
   acervo[destino].codigo <- acervo[origem].codigo
   acervo[destino].titulo <- acervo[origem].titulo
   acervo[destino].autor <- acervo[origem].autor
   acervo[destino].ano <- acervo[origem].ano
   acervo[destino].categoria <- acervo[origem].categoria
   acervo[destino].qtdTotal <- acervo[origem].qtdTotal
   acervo[destino].qtdDisponivel <- acervo[origem].qtdDisponivel
   acervo[destino].qtdEmprestimos <- acervo[origem].qtdEmprestimos
   acervo[destino].status <- acervo[origem].status
fimprocedimento

procedimento copiarParaRanking(origem, destino: inteiro)   // acervo -> ranking
inicio
   ranking[destino].codigo <- acervo[origem].codigo
   ranking[destino].titulo <- acervo[origem].titulo
   ranking[destino].autor <- acervo[origem].autor
   ranking[destino].ano <- acervo[origem].ano
   ranking[destino].categoria <- acervo[origem].categoria
   ranking[destino].qtdTotal <- acervo[origem].qtdTotal
   ranking[destino].qtdDisponivel <- acervo[origem].qtdDisponivel
   ranking[destino].qtdEmprestimos <- acervo[origem].qtdEmprestimos
   ranking[destino].status <- acervo[origem].status
fimprocedimento

// Troca dois registros INTEIROS do ranking (nenhum campo fica para tras)
procedimento trocarRanking(a, b: inteiro)
var
   auxCodigo, auxAno, auxCat, auxTotal, auxDisp, auxEmp, auxStatus: inteiro
   auxTitulo, auxAutor: caractere
inicio
   auxCodigo <- ranking[a].codigo
   auxTitulo <- ranking[a].titulo
   auxAutor <- ranking[a].autor
   auxAno <- ranking[a].ano
   auxCat <- ranking[a].categoria
   auxTotal <- ranking[a].qtdTotal
   auxDisp <- ranking[a].qtdDisponivel
   auxEmp <- ranking[a].qtdEmprestimos
   auxStatus <- ranking[a].status

   ranking[a].codigo <- ranking[b].codigo
   ranking[a].titulo <- ranking[b].titulo
   ranking[a].autor <- ranking[b].autor
   ranking[a].ano <- ranking[b].ano
   ranking[a].categoria <- ranking[b].categoria
   ranking[a].qtdTotal <- ranking[b].qtdTotal
   ranking[a].qtdDisponivel <- ranking[b].qtdDisponivel
   ranking[a].qtdEmprestimos <- ranking[b].qtdEmprestimos
   ranking[a].status <- ranking[b].status

   ranking[b].codigo <- auxCodigo
   ranking[b].titulo <- auxTitulo
   ranking[b].autor <- auxAutor
   ranking[b].ano <- auxAno
   ranking[b].categoria <- auxCat
   ranking[b].qtdTotal <- auxTotal
   ranking[b].qtdDisponivel <- auxDisp
   ranking[b].qtdEmprestimos <- auxEmp
   ranking[b].status <- auxStatus
fimprocedimento

// ============================================================
// CADASTRO
// ============================================================
// Posicao onde o novo codigo deve entrar para manter o acervo ordenado
funcao posicaoInsercao(cod: inteiro): inteiro
var p: inteiro
inicio
   p <- 1
   enquanto (p <= qtdLivros) e (acervo[p].codigo < cod) faca
      p <- p + 1
   fimenquanto
   retorne p
fimfuncao

// Insere (sem ler nada do teclado) mantendo a ordem por codigo
procedimento inserirLivro(cod: inteiro; tit, aut: caractere; anoPub, cat, qtd: inteiro)
var i, p: inteiro
inicio
   p <- posicaoInsercao(cod)
   // abre espaco deslocando os registros para a direita
   para i de qtdLivros ate p passo -1 faca
      copiarLivro(i, i + 1)
   fimpara
   acervo[p].codigo <- cod
   acervo[p].titulo <- tit
   acervo[p].autor <- aut
   acervo[p].ano <- anoPub
   acervo[p].categoria <- cat
   acervo[p].qtdTotal <- qtd
   acervo[p].qtdDisponivel <- qtd
   acervo[p].qtdEmprestimos <- 0
   acervo[p].status <- DISPONIVEL
   qtdLivros <- qtdLivros + 1
   livrosPorCat[cat] <- livrosPorCat[cat] + 1
fimprocedimento

// Le e valida titulo, autor, ano, categoria e quantidade.
// Parametros "var" = passagem por referencia: o procedimento PRECISA devolver os valores.
procedimento lerDadosLivro(var tit, aut: caractere; var anoPub, cat, qtd: inteiro)
inicio
   repita
      escreva("Titulo: ")
      leia(tit)
      se tit = "" entao
         escreval("  Titulo nao pode ser vazio!")
      fimse
   ate tit <> ""
   repita
      escreva("Autor: ")
      leia(aut)
      se aut = "" entao
         escreval("  Autor nao pode ser vazio!")
      fimse
   ate aut <> ""
   anoPub <- lerInteiroFaixa("Ano de publicacao: ", ANO_MIN, ANO_MAX)
   escreval("Categorias: 1-Tecnologia 2-Ciencias Exatas 3-Ciencias Humanas 4-Adm. e Negocios 5-Literatura")
   cat <- lerInteiroFaixa("Categoria: ", TECNOLOGIA, MAX_CATEGORIAS)
   qtd <- lerInteiroFaixa("Quantidade de exemplares: ", 1, 999)
fimprocedimento

procedimento cadastrarLivro
var
   cod, anoPub, cat, qtd: inteiro
   tit, aut: caractere
   cancelou, codigoOk: logico
inicio
   se qtdLivros >= MAX_LIVROS entao
      escreval("Capacidade maxima do acervo atingida (", MAX_LIVROS, " livros)!")
   senao
      cancelou <- falso
      codigoOk <- falso
      repita
         escreva("Codigo do livro (0 para cancelar): ")
         leia(cod)
         se cod = 0 entao
            cancelou <- verdadeiro
         senao
            se cod < 0 entao
               escreval("  Codigo invalido! Use um numero positivo.")
            senao
               se localizarLivro(cod) <> NAO_ENCONTRADO entao
                  escreval("  Codigo duplicado! Ja existe um livro com o codigo ", cod, ".")
               senao
                  codigoOk <- verdadeiro
               fimse
            fimse
         fimse
      ate cancelou ou codigoOk

      se nao cancelou entao
         lerDadosLivro(tit, aut, anoPub, cat, qtd)
         inserirLivro(cod, tit, aut, anoPub, cat, qtd)
         escreval("Livro cadastrado com sucesso!")
      senao
         escreval("Cadastro cancelado.")
      fimse
   fimse
fimprocedimento

// ============================================================
// LISTAGEM E CONSULTA
// ============================================================
procedimento mostrarLivro(posicao: inteiro)
inicio
   escreval("Codigo............: ", acervo[posicao].codigo)
   escreval("Titulo............: ", acervo[posicao].titulo)
   escreval("Autor.............: ", acervo[posicao].autor)
   escreval("Ano...............: ", acervo[posicao].ano)
   escreval("Categoria.........: ", nomeCategoria(acervo[posicao].categoria))
   escreval("Exemplares total..: ", acervo[posicao].qtdTotal)
   escreval("Exemplares disp...: ", acervo[posicao].qtdDisponivel)
   escreval("Exemplares emprest: ", qtdEmprestada(posicao))
   escreval("Total emprestimos.: ", acervo[posicao].qtdEmprestimos)
   escreval("Status............: ", nomeStatus(acervo[posicao].status))
fimprocedimento

procedimento listarAcervo
var i: inteiro
inicio
   se catalogoVazio(qtdLivros) entao
      escreval("O acervo esta vazio!")
   senao
      escreval("COD | TITULO | AUTOR | ANO | CATEGORIA | TOTAL | DISP | EMPREST. | STATUS")
      para i de 1 ate qtdLivros faca
         escreval(acervo[i].codigo, " | ", acervo[i].titulo, " | ", acervo[i].autor, " | ", acervo[i].ano, " | ", nomeCategoria(acervo[i].categoria), " | ", acervo[i].qtdTotal, " | ", acervo[i].qtdDisponivel, " | ", acervo[i].qtdEmprestimos, " | ", nomeStatus(acervo[i].status))
      fimpara
   fimse
fimprocedimento

procedimento consultarLivro
var cod, posicao: inteiro
inicio
   se catalogoVazio(qtdLivros) entao
      escreval("O acervo esta vazio! Nada para consultar.")
   senao
      escreva("Codigo do livro: ")
      leia(cod)
      posicao <- localizarLivro(cod)
      se posicao = NAO_ENCONTRADO entao
         escreval("Livro de codigo ", cod, " nao encontrado.")
      senao
         mostrarLivro(posicao)
      fimse
   fimse
fimprocedimento

procedimento exibirDisponiveis
var i, cont: inteiro
inicio
   se catalogoVazio(qtdLivros) entao
      escreval("O acervo esta vazio!")
   senao
      cont <- 0
      escreval("LIVROS DISPONIVEIS PARA EMPRESTIMO")
      para i de 1 ate qtdLivros faca
         se (acervo[i].status = DISPONIVEL) e (acervo[i].qtdDisponivel > 0) entao
            escreval(acervo[i].codigo, " | ", acervo[i].titulo, " | ", acervo[i].autor, " | Disponiveis: ", acervo[i].qtdDisponivel, " de ", acervo[i].qtdTotal)
            cont <- cont + 1
         fimse
      fimpara
      se cont = 0 entao
         escreval("Nenhum livro disponivel no momento.")
      senao
         escreval("Total de titulos disponiveis: ", cont)
      fimse
   fimse
fimprocedimento

// ============================================================
// EMPRESTIMO E DEVOLUCAO
// ============================================================
// Aplica o emprestimo (ja validado) ao livro da posicao informada
procedimento emprestar(posicao: inteiro)
var cat: inteiro
inicio
   cat <- acervo[posicao].categoria
   acervo[posicao].qtdDisponivel <- acervo[posicao].qtdDisponivel - 1
   acervo[posicao].qtdEmprestimos <- acervo[posicao].qtdEmprestimos + 1
   movimentacoes[cat, EMPRESTIMO] <- movimentacoes[cat, EMPRESTIMO] + 1
   se acervo[posicao].qtdDisponivel = 0 entao
      acervo[posicao].status <- INDISPONIVEL
   fimse
fimprocedimento

// Aplica a devolucao (ja validada) ao livro da posicao informada
procedimento devolver(posicao: inteiro)
var cat: inteiro
inicio
   cat <- acervo[posicao].categoria
   acervo[posicao].qtdDisponivel <- acervo[posicao].qtdDisponivel + 1
   movimentacoes[cat, DEVOLUCAO] <- movimentacoes[cat, DEVOLUCAO] + 1
   acervo[posicao].status <- DISPONIVEL
fimprocedimento

procedimento realizarEmprestimo
var
   cod, posicao: inteiro
   livroExiste: logico
inicio
   se catalogoVazio(qtdLivros) entao
      escreval("O acervo esta vazio! Nao ha livros para emprestar.")
   senao
      escreva("Codigo do livro a emprestar: ")
      leia(cod)
      posicao <- localizarLivro(cod)
      livroExiste <- (posicao <> NAO_ENCONTRADO)
      se nao livroExiste entao
         escreval("Livro de codigo ", cod, " nao encontrado.")
      senao
         se (acervo[posicao].qtdDisponivel > 0) e (acervo[posicao].status = DISPONIVEL) entao
            emprestar(posicao)
            escreval("Emprestimo realizado: ", acervo[posicao].titulo)
            escreval("Exemplares disponiveis agora: ", acervo[posicao].qtdDisponivel)
            se acervo[posicao].status = INDISPONIVEL entao
               escreval("Atencao: esse era o ultimo exemplar disponivel!")
            fimse
         senao
            escreval("Emprestimo negado: nao ha exemplares disponiveis de '", acervo[posicao].titulo, "'.")
         fimse
      fimse
   fimse
fimprocedimento

procedimento realizarDevolucao
var cod, posicao: inteiro
inicio
   se catalogoVazio(qtdLivros) entao
      escreval("O acervo esta vazio! Nao ha devolucoes possiveis.")
   senao
      escreva("Codigo do livro a devolver: ")
      leia(cod)
      posicao <- localizarLivro(cod)
      se posicao = NAO_ENCONTRADO entao
         escreval("Livro de codigo ", cod, " nao encontrado.")
      senao
         // so devolve se ha exemplar emprestado e a devolucao nao passa do total
         se (qtdEmprestada(posicao) > 0) e (acervo[posicao].qtdDisponivel < acervo[posicao].qtdTotal) entao
            devolver(posicao)
            escreval("Devolucao registrada: ", acervo[posicao].titulo)
            escreval("Exemplares disponiveis agora: ", acervo[posicao].qtdDisponivel)
         senao
            escreval("Devolucao negada: todos os exemplares de '", acervo[posicao].titulo, "' ja estao na biblioteca.")
         fimse
      fimse
   fimse
fimprocedimento

// ============================================================
// RANKING (Bubble Sort em registros, 3 criterios)
// ============================================================
// Retorna VERDADEIRO se ranking[a] deve ficar ANTES de ranking[b]:
// 1) mais emprestimos; 2) menos disponiveis; 3) titulo em ordem alfabetica
funcao vemAntes(a, b: inteiro): logico
var resultado: logico
inicio
   se ranking[a].qtdEmprestimos <> ranking[b].qtdEmprestimos entao
      resultado <- (ranking[a].qtdEmprestimos > ranking[b].qtdEmprestimos)
   senao
      se ranking[a].qtdDisponivel <> ranking[b].qtdDisponivel entao
         resultado <- (ranking[a].qtdDisponivel < ranking[b].qtdDisponivel)
      senao
         resultado <- (maiusc(ranking[a].titulo) < maiusc(ranking[b].titulo))
      fimse
   fimse
   retorne resultado
fimfuncao

procedimento ordenarRanking
var i, j: inteiro
inicio
   // copia o acervo para nao desordenar o vetor usado na busca por codigo
   para i de 1 ate qtdLivros faca
      copiarParaRanking(i, i)
   fimpara
   // Bubble Sort: a cada passada o "pior" livro afunda para o fim
   para i de 1 ate qtdLivros - 1 faca
      para j de 1 ate qtdLivros - i faca
         se vemAntes(j + 1, j) entao
            trocarRanking(j, j + 1)
         fimse
      fimpara
   fimpara
fimprocedimento

procedimento exibirRanking
var i: inteiro
inicio
   se catalogoVazio(qtdLivros) entao
      escreval("O acervo esta vazio! Nao ha ranking.")
   senao
      ordenarRanking
      escreval("POSICAO | LIVRO | AUTOR | EMPRESTIMOS | DISPONIVEIS")
      para i de 1 ate qtdLivros faca
         escreval(i, " | ", ranking[i].titulo, " | ", ranking[i].autor, " | ", ranking[i].qtdEmprestimos, " | ", ranking[i].qtdDisponivel)
      fimpara
   fimse
fimprocedimento

// ============================================================
// MATRIZ DE MOVIMENTACOES (repeticoes aninhadas)
// ============================================================
procedimento exibirMatriz
var i, j, totalEmp, totalDev, totalGeral: inteiro
inicio
   totalEmp <- 0
   totalDev <- 0
   totalGeral <- 0
   escreval("CATEGORIA | EMPRESTIMOS | DEVOLUCOES")
   para i de 1 ate MAX_CATEGORIAS faca
      escreva(nomeCategoria(i))
      para j de 1 ate TIPOS_OPERACAO faca
         escreva(" | ", movimentacoes[i, j])
         totalGeral <- totalGeral + movimentacoes[i, j]      // acumulador geral
         se j = EMPRESTIMO entao
            totalEmp <- totalEmp + movimentacoes[i, j]
         senao
            totalDev <- totalDev + movimentacoes[i, j]
         fimse
      fimpara
      escreval("")
   fimpara
   escreval("TOTAL | ", totalEmp, " | ", totalDev)
   escreval("Total de movimentacoes na matriz: ", totalGeral)
fimprocedimento

// ============================================================
// ESTATISTICAS
// ============================================================
procedimento gerarEstatisticas
var
   i: inteiro
   totalExemplares, totalDisp, totalEmprestados: inteiro
   totalEmprestimos, totalDevolucoes: inteiro
   posMaxEmp, posMaxDisp, catMaior, maiorQtd: inteiro
   percDisp, percEmp, media: real
inicio
   se catalogoVazio(qtdLivros) entao
      escreval("O acervo esta vazio! Nao ha estatisticas.")
   senao
      totalExemplares <- 0
      totalDisp <- 0
      totalEmprestados <- 0
      posMaxEmp <- 1
      posMaxDisp <- 1

      // percorre o acervo: acumuladores e "maiores"
      para i de 1 ate qtdLivros faca
         totalExemplares <- totalExemplares + acervo[i].qtdTotal
         totalDisp <- totalDisp + acervo[i].qtdDisponivel
         totalEmprestados <- totalEmprestados + qtdEmprestada(i)
         se acervo[i].qtdEmprestimos > acervo[posMaxEmp].qtdEmprestimos entao
            posMaxEmp <- i
         fimse
         se acervo[i].qtdDisponivel > acervo[posMaxDisp].qtdDisponivel entao
            posMaxDisp <- i
         fimse
      fimpara

      // percorre a matriz: totais e categoria com mais emprestimos
      totalEmprestimos <- 0
      totalDevolucoes <- 0
      catMaior <- 1
      maiorQtd <- movimentacoes[1, EMPRESTIMO]
      para i de 1 ate MAX_CATEGORIAS faca
         totalEmprestimos <- totalEmprestimos + movimentacoes[i, EMPRESTIMO]
         totalDevolucoes <- totalDevolucoes + movimentacoes[i, DEVOLUCAO]
         se movimentacoes[i, EMPRESTIMO] > maiorQtd entao
            maiorQtd <- movimentacoes[i, EMPRESTIMO]
            catMaior <- i
         fimse
      fimpara

      percDisp <- (totalDisp / totalExemplares) * 100
      percEmp <- (totalEmprestados / totalExemplares) * 100
      media <- totalExemplares / qtdLivros

      escreval("===== ESTATISTICAS GERAIS =====")
      escreval("Livros cadastrados..............: ", qtdLivros)
      escreval("Total de exemplares.............: ", totalExemplares)
      escreval("Exemplares disponiveis..........: ", totalDisp)
      escreval("Exemplares emprestados agora....: ", totalEmprestados)
      escreval("Total de emprestimos realizados.: ", totalEmprestimos)
      escreval("Total de devolucoes.............: ", totalDevolucoes)
      escreval("Percentual disponivel...........: ", percDisp:6:2, "%")
      escreval("Percentual emprestado...........: ", percEmp:6:2, "%")
      escreval("Media de exemplares por livro...: ", media:6:2)
      se acervo[posMaxEmp].qtdEmprestimos > 0 entao
         escreval("Livro mais emprestado...........: ", acervo[posMaxEmp].titulo, " (", acervo[posMaxEmp].qtdEmprestimos, ")")
      senao
         escreval("Livro mais emprestado...........: nenhum emprestimo registrado")
      fimse
      escreval("Livro com mais disponiveis......: ", acervo[posMaxDisp].titulo, " (", acervo[posMaxDisp].qtdDisponivel, ")")
      se maiorQtd > 0 entao
         escreval("Categoria com mais emprestimos..: ", nomeCategoria(catMaior), " (", maiorQtd, ")")
      senao
         escreval("Categoria com mais emprestimos..: nenhuma (sem emprestimos)")
      fimse
      escreval("")
      escreval("--- Livros por categoria ---")
      para i de 1 ate MAX_CATEGORIAS faca
         escreval(nomeCategoria(i), ": ", livrosPorCat[i])
      fimpara
      escreval("")
      escreval("--- Movimentacoes por categoria ---")
      exibirMatriz
   fimse
fimprocedimento

// ============================================================
// BUSCA RECURSIVA (binaria) - acervo ordenado por codigo
// ============================================================
// esq e dir delimitam o intervalo pesquisado; a cada chamada ele cai pela metade.
// Caso-base 1: esq > dir              -> intervalo vazio -> retorna NAO_ENCONTRADO
// Caso-base 2: codigo do meio = cod   -> retorna meio
funcao buscaRecursiva(cod, esq, dir: inteiro): inteiro
var meio: inteiro
inicio
   se esq > dir entao
      retorne NAO_ENCONTRADO
   fimse
   meio <- (esq + dir) \ 2
   escreval("  Intervalo [", esq, "..", dir, "] -> meio = posicao ", meio, " (codigo ", acervo[meio].codigo, ")")
   se acervo[meio].codigo = cod entao
      retorne meio
   senao
      se cod < acervo[meio].codigo entao
         retorne buscaRecursiva(cod, esq, meio - 1)      // metade inferior
      senao
         retorne buscaRecursiva(cod, meio + 1, dir)      // metade superior
      fimse
   fimse
fimfuncao

procedimento buscarRecursivo
var cod, posicao: inteiro
inicio
   se catalogoVazio(qtdLivros) entao
      escreval("O acervo esta vazio! Nada para buscar.")
   senao
      escreva("Codigo a buscar: ")
      leia(cod)
      escreval("Passos da busca binaria:")
      posicao <- buscaRecursiva(cod, 1, qtdLivros)
      se posicao = NAO_ENCONTRADO entao
         escreval("Resultado: codigo ", cod, " NAO encontrado no catalogo.")
      senao
         escreval("Resultado: codigo ", cod, " encontrado na posicao ", posicao, ".")
         mostrarLivro(posicao)
      fimse
   fimse
fimprocedimento

// ============================================================
// DADOS DE TESTE (opcao auxiliar 0 - pode ser removida na entrega)
// Usa os codigos do desafio: 10 18 25 32 47 53 61 74 82
// ============================================================
procedimento carregarDadosTeste
var k: inteiro
inicio
   se qtdLivros > 0 entao
      escreval("Dados de teste so podem ser carregados com o acervo vazio.")
   senao
      // inseridos fora de ordem para testar a insercao ordenada
      inserirLivro(47, "Algoritmos e Estruturas de Dados", "Wirth", 1986, 1, 3)
      inserirLivro(10, "Logica de Programacao", "Forbellone", 2005, 1, 4)
      inserirLivro(82, "Calculo Volume 1", "Stewart", 2013, 2, 2)
      inserirLivro(25, "Algebra Linear", "Boldrini", 1986, 2, 2)
      inserirLivro(61, "Sociologia Geral", "Giddens", 2012, 3, 3)
      inserirLivro(18, "Antropologia Cultural", "Laraia", 2001, 3, 2)
      inserirLivro(74, "Administracao Geral", "Chiavenato", 2014, 4, 5)
      inserirLivro(32, "Marketing Essencial", "Kotler", 2010, 4, 3)
      inserirLivro(53, "Dom Casmurro", "Machado de Assis", 1899, 5, 2)

      para k de 1 ate 3 faca
         emprestar(localizarLivro(10))      // 3 emprestimos
         emprestar(localizarLivro(61))      // 3 emprestimos (zera -> indisponivel)
      fimpara
      devolver(localizarLivro(10))
      emprestar(localizarLivro(25))         // 25 e 18 empatam em emprestimos e
      emprestar(localizarLivro(18))         // disponiveis: desempate por titulo
      para k de 1 ate 2 faca
         emprestar(localizarLivro(74))
         emprestar(localizarLivro(53))
      fimpara
      devolver(localizarLivro(74))
      devolver(localizarLivro(53))
      escreval("9 livros de teste carregados com movimentacoes.")
   fimse
fimprocedimento

// ============================================================
// MENU
// ============================================================
procedimento exibirMenu
inicio
   escreval("")
   escreval("==========================================================")
   escreval("  UNILIBRARY - SISTEMA DE GERENCIAMENTO DE BIBLIOTECA")
   escreval("==========================================================")
   escreval("  1. Cadastrar livro")
   escreval("  2. Listar acervo")
   escreval("  3. Consultar livro")
   escreval("  4. Realizar emprestimo")
   escreval("  5. Realizar devolucao")
   escreval("  6. Exibir livros disponiveis")
   escreval("  7. Exibir ranking do acervo")
   escreval("  8. Exibir estatisticas")
   escreval("  9. Realizar busca recursiva")
   escreval("  10. Encerrar sistema")
   escreval("  (0. Carregar dados de teste)")
   escreval("----------------------------------------------------------")
   escreva("Escolha uma opcao: ")
fimprocedimento

// ============================================================
// ALGORITMO PRINCIPAL: apenas orquestra as sub-rotinas
// ============================================================
inicio
   inicializar
   repita
      exibirMenu
      leia(opcao)
      escreval("")
      escolha opcao
         caso 1
            cadastrarLivro
         caso 2
            listarAcervo
         caso 3
            consultarLivro
         caso 4
            realizarEmprestimo
         caso 5
            realizarDevolucao
         caso 6
            exibirDisponiveis
         caso 7
            exibirRanking
         caso 8
            gerarEstatisticas
         caso 9
            buscarRecursivo
         caso 10
            escreval("Sistema encerrado. Ate logo!")
         caso 0
            carregarDadosTeste
         outrocaso
            escreval("Opcao invalida! Escolha um numero de 1 a 10.")
      fimescolha
   ate opcao = 10
fimalgoritmo