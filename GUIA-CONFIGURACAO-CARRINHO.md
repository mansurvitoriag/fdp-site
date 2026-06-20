# Guia de Configuração — Integração do Carrinho com a Shopify

Este guia te mostra como ativar a Storefront API e conectar nosso site
(o HTML que já fizemos) ao sistema de carrinho/checkout real da Shopify.

---

## Visão geral do que foi feito

- O site continua sendo **exatamente o nosso HTML/CSS**, hospedado onde você
  quiser (Hostinger, por exemplo) — nenhum tema da Shopify é usado.
- Cada produto agora tem um botão **"Adicionar ao carrinho"**.
- Existe um **ícone de carrinho flutuante** no canto da tela (em todas as
  páginas), que abre um painel lateral com os itens.
- Esse painel tem dois botões: **"Continuar comprando"** (fecha o painel,
  mantém os itens guardados) e **"Finalizar compra"** (leva para o checkout
  seguro da própria Shopify — esse último passo sempre acontece na Shopify,
  por exigência de segurança, mas tudo antes disso é no nosso site).
- A pessoa pode navegar entre páginas do site e os itens do carrinho
  continuam lá, porque o ID do carrinho é guardado no navegador dela.

---

## Passo 1 — Criar um app personalizado e gerar o token

A integração funciona através da **Storefront API**, que precisa de um
"token de acesso" para autenticar as requisições. Veja como gerar:

1. No admin da Shopify, vá em **Configurações → Apps e canais de vendas**.
2. Clique em **Desenvolver apps** (no canto superior direito da tela).
   - Se for a primeira vez, a Shopify vai pedir para você confirmar que
     quer habilitar o desenvolvimento de apps personalizados nessa loja.
     Confirme.
3. Clique em **Criar um app**.
4. Dê um nome para o app, por exemplo: `Site FDP - Carrinho`.
5. Depois de criado, vá na aba **Configuração da API** (Configuration).
6. Procure a seção **Storefront API** e clique em **Configurar**
   (Configure).
7. Marque as seguintes permissões (scopes) como habilitadas:
   - `unauthenticated_read_product_listings`
   - `unauthenticated_read_product_inventory`
   - `unauthenticated_write_checkouts` (ou `unauthenticated_write_carts`,
     dependendo da versão exibida)
   - `unauthenticated_read_checkouts` (ou `unauthenticated_read_carts`)
8. Salve.
9. Vá na aba **Credenciais da API** (API credentials).
10. Clique em **Instalar app**.
11. Depois de instalado, você vai ver um campo chamado
    **"Storefront API access token"** — clique em **Revelar token uma vez**
    (Reveal token once) e copie esse valor.

**Importante:** esse token (Storefront Access Token) é diferente da senha
do seu admin e é seguro para usar em código público no navegador — ele só
permite ações de loja (ver produtos, criar carrinho), não dá acesso
administrativo à sua loja.

---

## Passo 2 — Preencher a configuração no arquivo `fdp-cart.js`

Abra o arquivo `fdp-cart.js` (está dentro da pasta `assets` do site) e
edite estas três linhas no topo:

```javascript
const FDP_SHOPIFY_CONFIG = {
  dominio: "SUA-LOJA.myshopify.com",
  storefrontToken: "SEU_STOREFRONT_ACCESS_TOKEN_AQUI",
  apiVersion: "2026-01",
};
```

- **dominio**: o domínio `.myshopify.com` da sua loja (não é o
  `futdasparcas.com.br` — é o domínio interno da Shopify, você encontra
  em Configurações → Domínios, ou na própria URL do admin).
- **storefrontToken**: cole o token que você copiou no Passo 1.
- **apiVersion**: pode deixar como está; revise esse número a cada
  6-12 meses (a Shopify atualiza a versão da API periodicamente).

---

## Passo 3 — Cadastrar produtos e pegar o ID de cada variante

1. No admin, vá em **Produtos → Adicionar produto**.
2. Cadastre normalmente (nome, preço, fotos, estoque).
3. Depois de salvar, você precisa do **ID da variante** desse produto
   para conectar ao botão "Adicionar ao carrinho" no nosso HTML.

### Como encontrar o ID da variante:

**Opção simples (sem código):**
1. Abra o produto no admin.
2. Olhe a URL do navegador quando você está na aba de variantes —
   geralmente aparece um número longo.
3. Ou use a extensão/app gratuita "Postman" ou o **GraphiQL Explorer**
   da própria Shopify (disponível em Configurações → Apps →
   [seu app] → API access → "Abrir no GraphiQL") para rodar esta consulta:

```graphql
{
  products(first: 10) {
    edges {
      node {
        title
        variants(first: 5) {
          edges {
            node {
              id
              title
            }
          }
        }
      }
    }
  }
}
```

Isso retorna algo como:
```
"id": "gid://shopify/ProductVariant/45123456789012"
```

Esse valor completo (começando com `gid://shopify/ProductVariant/...`)
é o que você cola no `data-variant-id` de cada botão no HTML.

---

## Passo 4 — Conectar cada botão ao produto certo

No arquivo `loja.html` (e nos produtos da `index.html`), cada produto
tem um botão assim:

```html
<button class="btn-ver-mais" ...
  data-variant-id="gid://shopify/ProductVariant/PLACEHOLDER_001"
  onclick="fdpAddToCartAndOpen(this.dataset.variantId, 1, this)">
  Adicionar ao carrinho
</button>
```

Troque `PLACEHOLDER_001` (e os outros `PLACEHOLDER_002`, `003`...) pelo
ID real da variante do produto correspondente, que você pegou no Passo 3.

Também é uma boa hora para:
- Trocar a imagem placeholder de cada produto pela foto real.
- Trocar o título e preço exibido (são só visuais — o preço cobrado de
  verdade no checkout vem direto da Shopify, então mantenha sempre os
  dois iguais para não confundir o cliente).

---

## Passo 5 — Testar antes de publicar

1. Suba os arquivos atualizados na sua hospedagem (Hostinger).
2. Abra o site publicado e clique em "Adicionar ao carrinho" em um produto.
3. O painel lateral deve abrir mostrando o item.
4. Clique em "Continuar comprando" — o painel fecha, mas o item continua
   no carrinho (teste navegando para outra página e abrindo o carrinho
   de novo pelo ícone flutuante).
5. Clique em "Finalizar compra" — deve te levar para uma página seria
   `https://sua-loja.myshopify.com/cart/c/...` ou seu domínio de checkout,
   onde a pessoa preenche endereço e pagamento normalmente.

Se algo não funcionar, abra o **Console do navegador** (botão direito
→ Inspecionar → aba Console) e veja se aparece alguma mensagem de erro
em vermelho — geralmente indica token errado, domínio errado, ou
permissão (scope) não habilitada no Passo 1.

---

## Observações importantes

- **Sem produtos cadastrados, os botões não vão funcionar** — é
  necessário ter ao menos 1 produto real para testar de ponta a ponta.
- O carrinho funciona mesmo com a Shopify usando outro tema/configuração
  por trás — não precisa publicar nenhum tema específico, só ter a loja
  ativa com produtos e o canal de vendas "Online Store" habilitado
  (mesmo que você não use o tema dela para exibir nada).
- Carrinhos abandonados expiram automaticamente em 30 dias.
- Se quiser, depois também é possível mostrar dados de frete, cupons de
  desconto, etc., diretamente no nosso painel lateral — me avise se
  quiser evoluir isso.
