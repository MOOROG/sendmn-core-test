USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[temp_tran]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[temp_tran](
	[tran_id] [int] IDENTITY(1,1) NOT NULL,
	[sessionID] [varchar](50) NULL,
	[agent_id] [int] NULL,
	[branch_id] [int] NULL,
	[entry_user_id] [varchar](20) NULL,
	[acct_num] [varchar](100) NULL,
	[gl_sub_head_code] [varchar](200) NULL,
	[module_id] [varchar](5) NULL,
	[part_tran_srl_num] [varchar](4) NULL,
	[part_tran_type] [varchar](2) NULL,
	[ref_num] [varchar](20) NULL,
	[rpt_code] [varchar](25) NULL,
	[tran_amt] [money] NULL,
	[tran_date] [datetime] NULL,
	[tran_particular] [varchar](500) NULL,
	[tran_rmks] [varchar](60) NULL,
	[vfd_date] [datetime] NULL,
	[vfd_user_id] [varchar](15) NULL,
	[billdate] [datetime] NULL,
	[billno] [varchar](20) NULL,
	[party] [int] NULL,
	[otherinfo] [varchar](52) NULL,
	[trn_currency] [varchar](5) NULL,
	[ex_rate] [money] NULL,
	[usd_rate] [money] NULL,
	[lc_amt_cr] [money] NULL,
	[v_type] [char](1) NULL,
	[refrence] [varchar](50) NULL,
	[isnew] [varchar](50) NULL,
	[RunningBalance] [money] NULL,
	[usd_amt] [money] NULL,
	[dept_id] [int] NULL,
	[emp_name] [varchar](100) NULL,
	[field1] [varchar](50) NULL,
	[field2] [varchar](50) NULL,
	[CHEQUE_NO] [varchar](50) NULL
) ON [PRIMARY]
GO
