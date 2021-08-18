#! /bin/env python

from __future__ import division
import unittest

from solartherm import simulation
from solartherm import postproc
import os

class TestSolsticePyFunc(unittest.TestCase):
	def setUp(self):
		fn = 'TestSolsticePyFunc.mo'
		sim = simulation.Simulator(fn)
		sim.compile_model()
		sim.compile_sim(args=['-s'])
		sim.simulate(start=0, stop=10, step=0.1)
		self.res = postproc.SimResult(sim.model + '_res.mat')


	def test_touching(self):
		self.assertTrue(abs(self.res.interpolate('nu', 0)-0.8834)/0.8834<0.01)
		os.system('rm TestSolsticePyFunc_*')
		os.system('rm TestSolsticePyFunc')
		os.system('rm TestSolsticePyFunc.c')
		os.system('rm TestSolsticePyFunc.o')
		os.system('rm TestSolsticePyFunc.makefile')
		os.system('rm -rf Test_SolsticePyFunc')

if __name__ == '__main__':
	unittest.main()

