import { rest } from 'msw';

// Known CEP fixture used across tests
const CEP_FIXTURE = {
  '01310100': {
    logradouro: 'Avenida Paulista',
    bairro: 'Bela Vista',
    localidade: 'São Paulo',
    uf: 'SP',
  },
};

export const handlers = [
  // ViaCEP — address lookup used by addressService.js
  rest.get('https://viacep.com.br/ws/:cep/json/', (req, res, ctx) => {
    const data = CEP_FIXTURE[req.params.cep];
    if (data) return res(ctx.json(data));
    return res(ctx.json({ erro: true }));
  }),
];
